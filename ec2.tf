# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Elastic IP - Wazuh
resource "aws_eip" "wazuh_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-wazuh-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Elastic IP - n8n
resource "aws_eip" "n8n_eip" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-n8n-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Wazuh EC2 Instance
resource "aws_instance" "wazuh" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.wazuh_instance_type
  subnet_id              = aws_subnet.soar_subnet.id
  vpc_security_group_ids = [aws_security_group.wazuh_sg.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.soar_profile.name

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = filebase64("${path.module}/userdata/wazuh.sh")

  tags = {
    Name        = "${var.project_name}-wazuh"
    Environment = var.environment
    Project     = var.project_name
    Role        = "SIEM"
  }
}

# n8n EC2 Instance
resource "aws_instance" "n8n" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.n8n_instance_type
  subnet_id              = aws_subnet.soar_subnet.id
  vpc_security_group_ids = [aws_security_group.n8n_sg.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.soar_profile.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = filebase64("${path.module}/userdata/n8n.sh")

  tags = {
    Name        = "${var.project_name}-n8n"
    Environment = var.environment
    Project     = var.project_name
    Role        = "SOAR"
  }
}

# EIP Associations
resource "aws_eip_association" "wazuh_eip_assoc" {
  instance_id   = aws_instance.wazuh.id
  allocation_id = aws_eip.wazuh_eip.id
}

resource "aws_eip_association" "n8n_eip_assoc" {
  instance_id   = aws_instance.n8n.id
  allocation_id = aws_eip.n8n_eip.id
}