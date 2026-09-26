output "vpc_id_output_network" {
  value       = aws_vpc.pipeline_vpc.id
  description = "value vpc id output network"
}

output "sn-pub-az1a_id_output_network" {
  value       = aws_subnet.sn-pub-az1a.id
  description = "value subnet public az1a id output network"
}

output "sn-priv-az1a_id_output_network" {
  value       = aws_subnet.sn-priv-az1a.id
  description = "value subnet private az1a id output network"
}

output "sn-pub-az1c_id_output_network" {
  value       = aws_subnet.sn-pub-az1c.id
  description = "value subnet public az1c id output network"
}

output "sn-priv-az1c_id_output_network" {
  value       = aws_subnet.sn-priv-az1c.id
  description = "value subnet private az1c id output network"
}