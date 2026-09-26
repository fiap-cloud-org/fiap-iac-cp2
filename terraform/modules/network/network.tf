# VPC 
resource "aws_vpc" "pipeline_vpc" {
  cidr_block = var.vpc_cidr_block_network

  tags = {
    Name        = "pipeline_vpc"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# SUBNET PUBLIC AZ1A
resource "aws_subnet" "sn-pub-az1a" {
  vpc_id                  = aws_vpc.pipeline_vpc.id
  cidr_block              = var.sn-pub-az1a_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name        = "sn-pub-az1a"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# SUBNET PRIVATE AZ1A
resource "aws_subnet" "sn-priv-az1a" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = var.sn-priv-az1a_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name        = "sn-priv-az1a"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# SUBNET PUBLIC AZ1C
resource "aws_subnet" "sn-pub-az1c" {
  vpc_id                  = aws_vpc.pipeline_vpc.id
  cidr_block              = var.sn-pub-az1c_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"

  tags = {
    Name        = "sn-pub-az1c"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# SUBNET PRIVATE AZ1C
resource "aws_subnet" "sn-priv-az1c" {
  vpc_id            = aws_vpc.pipeline_vpc.id
  cidr_block        = var.sn-priv-az1c_cidr_block
  availability_zone = "us-east-1c"

  tags = {
    Name        = "sn-priv-az1c"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pipeline_vpc.id

  tags = {
    Name        = "igw"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# EIP AZ1A
resource "aws_eip" "eip-ngw-az1a" {}

#NAT GATEWAY AZ1A
resource "aws_nat_gateway" "ngw-az1a" {
  allocation_id = aws_eip.eip-ngw-az1a.id
  subnet_id     = aws_subnet.sn-pub-az1a.id

  tags = {
    Name        = "ngw-az1a"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# EIP AZ1C
resource "aws_eip" "eip-ngw-az1c" {}

#NAT GATEWAY AZ1C
resource "aws_nat_gateway" "ngw-az1c" {
  allocation_id = aws_eip.eip-ngw-az1c.id
  subnet_id     = aws_subnet.sn-pub-az1c.id

  tags = {
    Name        = "ngw-az1c"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# ROUTE TABLE PUBLIC AZ1A
resource "aws_route_table" "rt-pub" {
  vpc_id = aws_vpc.pipeline_vpc.id

  route {
    cidr_block = var.rt-pub_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "rt-pub-az1a-az1c"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# ASSOCIATE ROUTE TABLE PUBLIC AZ1A
resource "aws_route_table_association" "rta-pub-az1a" {
  subnet_id      = aws_subnet.sn-pub-az1a.id
  route_table_id = aws_route_table.rt-pub.id
}

# ASSOCIATE ROUTE TABLE PUBLIC AZ1C
resource "aws_route_table_association" "rta-pub-az1c" {
  subnet_id      = aws_subnet.sn-pub-az1c.id
  route_table_id = aws_route_table.rt-pub.id
}

# ROUTE TABLE PRIVATE AZ1A
resource "aws_route_table" "rt-priv-az1a" {
  vpc_id = aws_vpc.pipeline_vpc.id

  route {
    cidr_block = var.rt-priv-az1a_cidr_block
    gateway_id = aws_nat_gateway.ngw-az1a.id
  }

  tags = {
    Name        = "rt-priv-az1a"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# ASSOCIATE ROUTE TABLE PRIVATE AZ1A
resource "aws_route_table_association" "rta-priv-az1a" {
  subnet_id      = aws_subnet.sn-priv-az1a.id
  route_table_id = aws_route_table.rt-priv-az1a.id
}

# ROUTE TABLE PRIVATE AZ1C
resource "aws_route_table" "rt-priv-az1c" {
  vpc_id = aws_vpc.pipeline_vpc.id

  route {
    cidr_block = var.rt-priv-az1c_cidr_block
    gateway_id = aws_nat_gateway.ngw-az1c.id
  }

  tags = {
    Name        = "rt-priv-az1c"
    Environment = "develop"
    Project     = "pipeline"
    ManagedBy   = "Terraform"
  }
}

# ASSOCIATE ROUTE TABLE PRIVATE AZ1C
resource "aws_route_table_association" "rta-priv-az1c" {
  subnet_id      = aws_subnet.sn-priv-az1c.id
  route_table_id = aws_route_table.rt-priv-az1c.id
}