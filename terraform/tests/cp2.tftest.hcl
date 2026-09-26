# terraform test com provider simulado: nenhuma chamada à AWS, nenhuma
# credencial. Testa cada módulo separado e depois a composição na raiz.
# Alguns atributos simulados precisam ter o formato real (ARN, lt-...), porque
# o provider valida as referências entre recursos.
mock_provider "aws" {
  mock_data "aws_ami" {
    defaults = {
      id = "ami-0123456789abcdef0"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/ec2-elb/0123456789abcdef"
      dns_name = "ec2-elb-123456789.us-east-1.elb.amazonaws.com"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/tg-ec2-elb/0123456789abcdef"
    }
  }

  mock_resource "aws_launch_template" {
    defaults = {
      id             = "lt-0123456789abcdef0"
      latest_version = 1
    }
  }
}

run "network" {
  command = apply

  module {
    source = "./modules/network"
  }

  variables {
    vpc_cidr_block_network  = "10.0.0.0/16"
    sn-pub-az1a_cidr_block  = "10.0.1.0/24"
    sn-priv-az1a_cidr_block = "10.0.2.0/24"
    sn-pub-az1c_cidr_block  = "10.0.3.0/24"
    sn-priv-az1c_cidr_block = "10.0.4.0/24"
    rt-pub_cidr_block       = "0.0.0.0/0"
    rt-priv-az1a_cidr_block = "0.0.0.0/0"
    rt-priv-az1c_cidr_block = "0.0.0.0/0"
  }

  assert {
    condition     = aws_subnet.sn-pub-az1a.availability_zone == "us-east-1a" && aws_subnet.sn-pub-az1c.availability_zone == "us-east-1c"
    error_message = "As sub-redes públicas devem ficar em us-east-1a e us-east-1c."
  }

  assert {
    condition     = aws_subnet.sn-priv-az1a.availability_zone == "us-east-1a" && aws_subnet.sn-priv-az1c.availability_zone == "us-east-1c"
    error_message = "As sub-redes privadas devem ficar em us-east-1a e us-east-1c."
  }

  assert {
    condition     = one(aws_route_table.rt-priv-az1a.route).nat_gateway_id == aws_nat_gateway.ngw-az1a.id
    error_message = "A rota privada da 1a deve sair pelo NAT da 1a (nat_gateway_id)."
  }

  assert {
    condition     = one(aws_route_table.rt-priv-az1c.route).nat_gateway_id == aws_nat_gateway.ngw-az1c.id
    error_message = "A rota privada da 1c deve sair pelo NAT da 1c (nat_gateway_id)."
  }

  assert {
    condition     = aws_nat_gateway.ngw-az1a.subnet_id == aws_subnet.sn-pub-az1a.id && aws_nat_gateway.ngw-az1c.subnet_id == aws_subnet.sn-pub-az1c.id
    error_message = "Cada NAT deve ficar na sub-rede pública da sua AZ."
  }

  assert {
    condition     = length(aws_default_security_group.default.ingress) == 0 && length(aws_default_security_group.default.egress) == 0
    error_message = "O SG default da VPC não pode ter regras."
  }
}

run "compute" {
  command = apply

  module {
    source = "./modules/compute"
  }

  variables {
    vpc_id_input_compute          = "vpc-0123456789abcdef0"
    sn-pub-az1a_id_input_compute  = "subnet-pub1a"
    sn-pub-az1c_id_input_compute  = "subnet-pub1c"
    sn-priv-az1a_id_input_compute = "subnet-priv1a"
    sn-priv-az1c_id_input_compute = "subnet-priv1c"
    egress_from_port_elb          = 0
    egress_to_port_elb            = 0
    egress_protocol_elb           = "-1"
    egress_cidr_blocks_elb        = ["0.0.0.0/0"]
    ingress_from_port_elb         = 80
    ingress_to_port_elb           = 80
    ingress_protocol_elb          = "tcp"
    ingress_cidr_blocks_elb       = ["0.0.0.0/0"]
    egress_from_port_ec2          = 0
    egress_to_port_ec2            = 0
    egress_protocol_ec2           = "-1"
    egress_cidr_blocks_ec2        = ["0.0.0.0/0"]
    ingress_from_port_ec2         = 80
    ingress_to_port_ec2           = 80
    ingress_protocol_ec2          = "tcp"
    min_size                      = 1
    max_size                      = 4
    desired_capacity              = 2
    instance_type                 = "t2.micro"
    key_name                      = null
  }

  assert {
    condition     = !aws_lb.ec2-elb.internal && toset(aws_lb.ec2-elb.subnets) == toset(["subnet-pub1a", "subnet-pub1c"])
    error_message = "O ALB público deve ficar nas sub-redes públicas."
  }

  assert {
    condition     = toset(aws_autoscaling_group.ec2-asg.vpc_zone_identifier) == toset(["subnet-priv1a", "subnet-priv1c"])
    error_message = "O ASG deve criar as instâncias nas sub-redes privadas."
  }

  assert {
    condition = alltrue([
      for r in aws_security_group.sg_ec2.ingress :
      try(length(r.cidr_blocks), 0) == 0 && contains(tolist(r.security_groups), aws_security_group.sg_elb.id)
    ])
    error_message = "As instâncias só podem aceitar tráfego do SG do ALB."
  }

  assert {
    condition     = one(aws_launch_template.ec2-launch-template.metadata_options).http_tokens == "required"
    error_message = "O launch template deve exigir IMDSv2."
  }

  assert {
    condition     = aws_launch_template.ec2-launch-template.image_id == "ami-0123456789abcdef0"
    error_message = "O launch template deve usar a AMI do data source."
  }

  assert {
    condition     = strcontains(base64decode(aws_launch_template.ec2-launch-template.user_data), "X-aws-ec2-metadata-token:")
    error_message = "O userdata deve ler os metadados com token (IMDSv2)."
  }

  assert {
    condition     = one(aws_lb_target_group.tg-ec2-elb.health_check).path == "/"
    error_message = "O target group precisa de health check em /."
  }
}

run "raiz" {
  command = apply

  assert {
    condition     = startswith(output.site_url, "http://")
    error_message = "O output site_url deve ser a URL HTTP do ALB."
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "Devem existir duas sub-redes privadas."
  }
}
