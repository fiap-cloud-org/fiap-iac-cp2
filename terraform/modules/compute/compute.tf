resource "aws_security_group" "sg_elb" {
  name        = "sg_elb"
  description = "ALB publico: HTTP da internet"
  vpc_id      = var.vpc_id_input_compute
  egress {
    description = "Saida para as instancias do ASG"
    from_port   = var.egress_from_port_elb
    to_port     = var.egress_to_port_elb
    protocol    = var.egress_protocol_elb
    cidr_blocks = var.egress_cidr_blocks_elb
  }
  ingress {
    description = "HTTP da internet"
    from_port   = var.ingress_from_port_elb
    to_port     = var.ingress_to_port_elb
    protocol    = var.ingress_protocol_elb
    cidr_blocks = var.ingress_cidr_blocks_elb
  }
}

resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "Instancias do ASG: HTTP so vindo do ALB"
  vpc_id      = var.vpc_id_input_compute
  egress {
    description = "Saida pelo NAT (pacotes do dnf)"
    from_port   = var.egress_from_port_ec2
    to_port     = var.egress_to_port_ec2
    protocol    = var.egress_protocol_ec2
    cidr_blocks = var.egress_cidr_blocks_ec2
  }
  ingress {
    description = "HTTP vindo do ALB"
    from_port   = var.ingress_from_port_ec2
    to_port     = var.ingress_to_port_ec2
    protocol    = var.ingress_protocol_ec2
    # Só o ALB fala com as instâncias; nada chega direto da internet.
    security_groups = [aws_security_group.sg_elb.id]
  }
}

resource "aws_lb_target_group" "tg-ec2-elb" {
  name     = "tg-ec2-elb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id_input_compute

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "ec2-elb" {
  name               = "ec2-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_elb.id]
  subnets            = [var.sn-pub-az1a_id_input_compute, var.sn-pub-az1c_id_input_compute]

  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.ec2-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ec2-elb.arn
  }
}


# Amazon Linux 2023 mais recente (a AMI fixa da entrega era um Amazon Linux 2
# de 2021).
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "ec2-launch-template" {
  name_prefix            = "app-dynamicsite"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  user_data              = filebase64("${path.module}/scripts/userdata.sh")

  # IMDSv2 obrigatório: o userdata já pede o token antes de ler os metadados.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "app-dynamicsite"
      Environment = "develop"
      Project     = "pipeline"
      ManagedBy   = "Terraform"
    }
  }
}

resource "aws_autoscaling_group" "ec2-asg" {
  name_prefix      = "ec2-asg-"
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  launch_template {
    id      = aws_launch_template.ec2-launch-template.id
    version = aws_launch_template.ec2-launch-template.latest_version
  }

  # Troca as instâncias aos poucos quando o launch template muda.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  target_group_arns   = [aws_lb_target_group.tg-ec2-elb.arn]
  vpc_zone_identifier = [var.sn-priv-az1a_id_input_compute, var.sn-priv-az1c_id_input_compute]

  tag {
    key                 = "Name"
    value               = "app-dynamicsite"
    propagate_at_launch = true
  }
}


