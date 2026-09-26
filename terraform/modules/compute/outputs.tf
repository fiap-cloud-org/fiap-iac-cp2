output "alb_dns_name_output_compute" {
  description = "DNS público do Application Load Balancer"
  value       = aws_lb.ec2-elb.dns_name
}

output "alb_arn_output_compute" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.ec2-elb.arn
}

output "target_group_arn_output_compute" {
  description = "ARN do target group das instâncias"
  value       = aws_lb_target_group.tg-ec2-elb.arn
}

output "asg_name_output_compute" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.ec2-asg.name
}

output "ami_id_output_compute" {
  description = "AMI usada pelo launch template"
  value       = data.aws_ami.al2023.id
}
