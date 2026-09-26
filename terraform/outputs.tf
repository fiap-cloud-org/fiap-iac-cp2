output "site_url" {
  description = "Endereço da página, servida pelo ALB"
  value       = "http://${module.compute.alb_dns_name_output_compute}"
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer"
  value       = module.compute.alb_dns_name_output_compute
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = module.compute.asg_name_output_compute
}

output "vpc_id" {
  description = "ID da VPC"
  value       = module.network.vpc_id_output_network
}

output "private_subnet_ids" {
  description = "Sub-redes privadas onde o ASG cria as instâncias"
  value = [
    module.network.sn-priv-az1a_id_output_network,
    module.network.sn-priv-az1c_id_output_network,
  ]
}
