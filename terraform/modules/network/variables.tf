variable "vpc_cidr_block_network" {
  description = "CIDR block for the VPC"
}

variable "sn-pub-az1a_cidr_block" {
  description = "subnet public az1a"
}

variable "sn-priv-az1a_cidr_block" {
  description = "subnet private az1a"
}

variable "sn-pub-az1c_cidr_block" {
  description = "subnet public az1c"
}

variable "sn-priv-az1c_cidr_block" {
  description = "subnet private az1c"
}

variable "rt-pub_cidr_block" {
  description = "route table public"
}

variable "rt-priv-az1a_cidr_block" {
  description = "route table private az1a"
}

variable "rt-priv-az1c_cidr_block" {
  description = "route table private az1c"
}