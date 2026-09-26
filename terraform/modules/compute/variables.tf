# VARIÁVEIS DE ENTRADA DO COMPUTE (IDs vindos do módulo network)
variable "vpc_id_input_compute" {
  description = "ID da VPC (saída do módulo network)"
  type        = string
}
variable "sn-pub-az1a_id_input_compute" {
  description = "ID da sub-rede pública us-east-1a"
  type        = string
}
variable "sn-priv-az1a_id_input_compute" {
  description = "ID da sub-rede privada us-east-1a"
  type        = string
}
variable "sn-pub-az1c_id_input_compute" {
  description = "ID da sub-rede pública us-east-1c"
  type        = string
}
variable "sn-priv-az1c_id_input_compute" {
  description = "ID da sub-rede privada us-east-1c"
  type        = string
}
#---------------------------------------------

# VARIÁVEIS DO SECURITY GROUP DO ALB
variable "egress_from_port_elb" {
  description = "Porta inicial da regra"
  type        = number
}

variable "egress_to_port_elb" {
  description = "Porta final da regra"
  type        = number
}

variable "egress_protocol_elb" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
}

variable "egress_cidr_blocks_elb" {
  description = "Faixas de IP da regra"
  type        = list(string)
}

variable "ingress_from_port_elb" {
  description = "Porta inicial da regra"
  type        = number
}

variable "ingress_to_port_elb" {
  description = "Porta final da regra"
  type        = number
}

variable "ingress_protocol_elb" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
}

variable "ingress_cidr_blocks_elb" {
  description = "Faixas de IP da regra"
  type        = list(string)
}

# VARIÁVEIS DO SECURITY GROUP DAS EC2
variable "egress_from_port_ec2" {
  description = "Porta inicial da regra"
  type        = number
}

variable "egress_to_port_ec2" {
  description = "Porta final da regra"
  type        = number
}

variable "egress_protocol_ec2" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
}

variable "egress_cidr_blocks_ec2" {
  description = "Faixas de IP da regra"
  type        = list(string)
}

variable "ingress_from_port_ec2" {
  description = "Porta inicial da regra"
  type        = number
}

variable "ingress_to_port_ec2" {
  description = "Porta final da regra"
  type        = number
}

variable "ingress_protocol_ec2" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
}


variable "min_size" {
  description = "Mínimo de instâncias no Auto Scaling Group"
  type        = number
}
# VARIÁVEIS DAS INSTÂNCIAS
variable "instance_type" {
  description = "Tipo das instâncias do ASG"
  type        = string
}

variable "key_name" {
  description = "Key pair para SSH (null = sem chave)"
  type        = string
}

variable "desired_capacity" {
  description = "Quantidade desejada de instâncias no ASG"
  type        = number
}

variable "max_size" {
  description = "Máximo de instâncias no ASG"
  type        = number
}
