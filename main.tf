terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "soar_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "soar_igw" {
  vpc_id = aws_vpc.soar_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnet
resource "aws_subnet" "soar_subnet" {
  vpc_id                  = aws_vpc.soar_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-subnet"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table
resource "aws_route_table" "soar_rt" {
  vpc_id = aws_vpc.soar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.soar_igw.id
  }

  tags = {
    Name        = "${var.project_name}-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Route Table Association
resource "aws_route_table_association" "soar_rta" {
  subnet_id      = aws_subnet.soar_subnet.id
  route_table_id = aws_route_table.soar_rt.id
}

# Security Group - Wazuh
resource "aws_security_group" "wazuh_sg" {
  name        = "${var.project_name}-wazuh-sg"
  description = "Security group for Wazuh SIEM"
  vpc_id      = aws_vpc.soar_vpc.id

  # SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "SSH from admin IP"
  }

  # Wazuh Dashboard
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "Wazuh Dashboard HTTPS"
  }

  # Wazuh Agent Communication
  ingress {
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Wazuh agent communication"
  }

  ingress {
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Wazuh agent enrollment"
  }

  # Wazuh API (for n8n integration)
  ingress {
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Wazuh API from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-wazuh-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group - n8n
resource "aws_security_group" "n8n_sg" {
  name        = "${var.project_name}-n8n-sg"
  description = "Security group for n8n SOAR"
  vpc_id      = aws_vpc.soar_vpc.id

  # SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "SSH from admin IP"
  }

  # n8n UI
  ingress {
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "n8n web UI"
  }

  # n8n webhook from Wazuh
  ingress {
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "n8n webhook from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-n8n-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}