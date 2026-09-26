variable "vpc_cidr_block_network" {
  description = "Faixa de IP da VPC"
  type        = string
}

variable "sn-pub-az1a_cidr_block" {
  description = "Faixa da sub-rede pública em us-east-1a"
  type        = string
}

variable "sn-priv-az1a_cidr_block" {
  description = "Faixa da sub-rede privada em us-east-1a"
  type        = string
}

variable "sn-pub-az1c_cidr_block" {
  description = "Faixa da sub-rede pública em us-east-1c"
  type        = string
}

variable "sn-priv-az1c_cidr_block" {
  description = "Faixa da sub-rede privada em us-east-1c"
  type        = string
}

variable "rt-pub_cidr_block" {
  description = "Destino da rota padrão da route table pública (vai para o IGW)"
  type        = string
}

variable "rt-priv-az1a_cidr_block" {
  description = "Destino da rota padrão da route table privada us-east-1a (vai para o NAT)"
  type        = string
}

variable "rt-priv-az1c_cidr_block" {
  description = "Destino da rota padrão da route table privada us-east-1c (vai para o NAT)"
  type        = string
}