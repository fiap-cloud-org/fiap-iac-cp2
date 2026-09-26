module "network" {

  source                  = "./modules/network"
  vpc_cidr_block_network  = var.vpc_cidr_block_main
  sn-pub-az1a_cidr_block  = var.sn-pub-az1a_cidr_block
  sn-priv-az1a_cidr_block = var.sn-priv-az1a_cidr_block
  sn-pub-az1c_cidr_block  = var.sn-pub-az1c_cidr_block
  sn-priv-az1c_cidr_block = var.sn-priv-az1c_cidr_block
  rt-pub_cidr_block       = var.rt-pub_cidr_block
  rt-priv-az1a_cidr_block = var.rt-priv-az1a_cidr_block
  rt-priv-az1c_cidr_block = var.rt-priv-az1c_cidr_block

}

module "compute" {
  source = "./modules/compute"

  egress_from_port_elb          = var.egress_from_port_elb
  egress_to_port_elb            = var.egress_to_port_elb
  egress_protocol_elb           = var.egress_protocol_elb
  egress_cidr_blocks_elb        = var.egress_cidr_blocks_elb
  ingress_from_port_elb         = var.ingress_from_port_elb
  ingress_to_port_elb           = var.ingress_to_port_elb
  ingress_protocol_elb          = var.ingress_protocol_elb
  ingress_cidr_blocks_elb       = var.ingress_cidr_blocks_elb
  egress_from_port_ec2          = var.egress_from_port_ec2
  egress_to_port_ec2            = var.egress_to_port_ec2
  egress_protocol_ec2           = var.egress_protocol_ec2
  egress_cidr_blocks_ec2        = var.egress_cidr_blocks_ec2
  ingress_from_port_ec2         = var.ingress_from_port_ec2
  ingress_to_port_ec2           = var.ingress_to_port_ec2
  ingress_protocol_ec2          = var.ingress_protocol_ec2
  ingress_cidr_blocks_ec2       = var.ingress_cidr_blocks_ec2
  vpc_id_imput_compute          = module.network.vpc_id_output_network
  sn-pub-az1a_id_imput_compute  = module.network.sn-pub-az1a_id_output_network
  sn-priv-az1a_id_imput_compute = module.network.sn-priv-az1a_id_output_network
  sn-pub-az1c_id_imput_compute  = module.network.sn-pub-az1c_id_output_network
  sn-priv-az1c_id_imput_compute = module.network.sn-priv-az1c_id_output_network
  min_size                      = var.min_size
}
