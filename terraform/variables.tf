variable "vpc_cidr_block_main" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


variable "sn-pub-az1a_cidr_block" {
  description = "subnet public az1a"
  default     = "10.0.1.0/24"
}

variable "sn-priv-az1a_cidr_block" {
  description = "subnet private az1a"
  default     = "10.0.2.0/24"
}

variable "sn-pub-az1c_cidr_block" {
  description = "subnet public az1c"
  default     = "10.0.3.0/24"
}

variable "sn-priv-az1c_cidr_block" {
  description = "subnet private az1c"
  default     = "10.0.4.0/24"
}

variable "rt-pub_cidr_block" {
  description = "route table public"
  default     = "0.0.0.0/0"
}

variable "rt-priv-az1a_cidr_block" {
  description = "route table private az1a"
  default     = "0.0.0.0/0"
}

variable "rt-priv-az1c_cidr_block" {
  description = "route table private az1c"
  default     = "0.0.0.0/0"
}

#VARIAVEIS DO SECURITY GROUP ELB

variable "egress_from_port_elb" {
  description = "value of from port"
  default     = "0"
}

variable "egress_to_port_elb" {
  description = "value of to port"
  default     = "0"
}

variable "egress_protocol_elb" {
  description = "value of protocol"
  default     = "-1"
}

variable "egress_cidr_blocks_elb" {
  description = "value of cidr blocks"
  default     = ["0.0.0.0/0"]
}

variable "ingress_from_port_elb" {
  description = "value of from port"
  default     = "80"
}

variable "ingress_to_port_elb" {
  description = "value of to port"
  default     = "80"
}

variable "ingress_protocol_elb" {
  description = "value of protocol"
  default     = "tcp"
}

variable "ingress_cidr_blocks_elb" {
  description = "value of cidr blocks"
  default     = ["0.0.0.0/0"]
}

#VARIAVEIS DO SECURITY GROUP EC2

variable "egress_from_port_ec2" {
  description = "value of from port"
  default     = "0"
}

variable "egress_to_port_ec2" {
  description = "value of to port"
  default     = "0"
}

variable "egress_protocol_ec2" {
  description = "value of protocol"
  default     = "-1"
}

variable "egress_cidr_blocks_ec2" {
  description = "value of cidr blocks"
  default     = ["0.0.0.0/0"]
}

variable "ingress_from_port_ec2" {
  description = "value of from port"
  default     = "80"
}

variable "ingress_to_port_ec2" {
  description = "value of to port"
  default     = "80"
}

variable "ingress_protocol_ec2" {
  description = "value of protocol"
  default     = "tcp"
}


variable "min_size" {
  description = "min size"
  default     = 1
}