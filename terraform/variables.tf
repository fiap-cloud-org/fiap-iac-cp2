variable "vpc_cidr_block_main" {
  description = "Faixa de IP da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "sn-pub-az1a_cidr_block" {
  description = "Faixa da sub-rede pública em us-east-1a"
  type        = string
  default     = "10.0.1.0/24"
}

variable "sn-priv-az1a_cidr_block" {
  description = "Faixa da sub-rede privada em us-east-1a"
  type        = string
  default     = "10.0.2.0/24"
}

variable "sn-pub-az1c_cidr_block" {
  description = "Faixa da sub-rede pública em us-east-1c"
  type        = string
  default     = "10.0.3.0/24"
}

variable "sn-priv-az1c_cidr_block" {
  description = "Faixa da sub-rede privada em us-east-1c"
  type        = string
  default     = "10.0.4.0/24"
}

variable "rt-pub_cidr_block" {
  description = "Destino da rota padrão da route table pública (vai para o IGW)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "rt-priv-az1a_cidr_block" {
  description = "Destino da rota padrão da route table privada us-east-1a (vai para o NAT)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "rt-priv-az1c_cidr_block" {
  description = "Destino da rota padrão da route table privada us-east-1c (vai para o NAT)"
  type        = string
  default     = "0.0.0.0/0"
}

# VARIÁVEIS DO SECURITY GROUP DO ALB

variable "egress_from_port_elb" {
  description = "Porta inicial da regra"
  type        = number
  default     = 0
}

variable "egress_to_port_elb" {
  description = "Porta final da regra"
  type        = number
  default     = 0
}

variable "egress_protocol_elb" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks_elb" {
  description = "Faixas de IP da regra"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_from_port_elb" {
  description = "Porta inicial da regra"
  type        = number
  default     = 80
}

variable "ingress_to_port_elb" {
  description = "Porta final da regra"
  type        = number
  default     = 80
}

variable "ingress_protocol_elb" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
  default     = "tcp"
}

variable "ingress_cidr_blocks_elb" {
  description = "Faixas de IP da regra"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# VARIÁVEIS DO SECURITY GROUP DAS EC2

variable "egress_from_port_ec2" {
  description = "Porta inicial da regra"
  type        = number
  default     = 0
}

variable "egress_to_port_ec2" {
  description = "Porta final da regra"
  type        = number
  default     = 0
}

variable "egress_protocol_ec2" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
  default     = "-1"
}

variable "egress_cidr_blocks_ec2" {
  description = "Faixas de IP da regra"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_from_port_ec2" {
  description = "Porta inicial da regra"
  type        = number
  default     = 80
}

variable "ingress_to_port_ec2" {
  description = "Porta final da regra"
  type        = number
  default     = 80
}

variable "ingress_protocol_ec2" {
  description = "Protocolo da regra (-1 = todos)"
  type        = string
  default     = "tcp"
}

variable "min_size" {
  description = "Mínimo de instâncias no Auto Scaling Group"
  type        = number
  default     = 1
}
# VARIÁVEIS DAS INSTÂNCIAS
variable "instance_type" {
  description = "Tipo das instâncias do ASG"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair existente para SSH nas instâncias (no AWS Academy: vockey). null cria sem chave; as instâncias ficam em sub-rede privada."
  type        = string
  default     = null
}

variable "desired_capacity" {
  description = "Quantidade desejada de instâncias no ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Máximo de instâncias no ASG"
  type        = number
  default     = 4
}
