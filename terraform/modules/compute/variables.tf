#VARIAVEIS DE IMPUT DO COMPUTE
variable "vpc_id_input_compute" {
  description = "vpc id input compute"
}
variable "sn-pub-az1a_id_input_compute" {
  description = "subnet public az1a id input compute"
}
variable "sn-priv-az1a_id_input_compute" {
  description = "subnet private az1a id input compute"
}
variable "sn-pub-az1c_id_input_compute" {
  description = "subnet public az1c id input compute"
}
variable "sn-priv-az1c_id_input_compute" {
  description = "subnet private az1c id input compute"
}
#---------------------------------------------

#VARIAVEIS DO SECURITY GROUP ELB
variable "egress_from_port_elb" {
  description = "value of from port"
}

variable "egress_to_port_elb" {
  description = "value of to port"
}

variable "egress_protocol_elb" {
  description = "value of protocol"
}

variable "egress_cidr_blocks_elb" {
  description = "value of cidr blocks"
}

variable "ingress_from_port_elb" {
  description = "value of from port"
}

variable "ingress_to_port_elb" {
  description = "value of to port"
}

variable "ingress_protocol_elb" {
  description = "value of protocol"
}

variable "ingress_cidr_blocks_elb" {
  description = "value of cidr blocks"
}

#VARIAVEIS DO SECURITY GROUP EC2
variable "egress_from_port_ec2" {
  description = "value of from port"
}

variable "egress_to_port_ec2" {
  description = "value of to port"
}

variable "egress_protocol_ec2" {
  description = "value of protocol"
}

variable "egress_cidr_blocks_ec2" {
  description = "value of cidr blocks"
}

variable "ingress_from_port_ec2" {
  description = "value of from port"
}

variable "ingress_to_port_ec2" {
  description = "value of to port"
}

variable "ingress_protocol_ec2" {
  description = "value of protocol"
}


variable "min_size" {
  description = "min size"
}