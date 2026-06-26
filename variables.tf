variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "soar-pipeline"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "wazuh_instance_type" {
  description = "EC2 instance type for Wazuh SIEM"
  type        = string
  default     = "t3.medium"
}

variable "n8n_instance_type" {
  description = "EC2 instance type for n8n SOAR"
  type        = string
  default     = "t3.small"
}

variable "your_ip" {
  description = "Your public IP address for SSH access (x.x.x.x/32)"
  type        = string
}

variable "key_pair_name" {
  description = "Name of existing AWS key pair for SSH access"
  type        = string
}

variable "s3_bucket_name" {
  description = "Unique name for the incident reports S3 bucket"
  type        = string
  default     = "soar-incident-reports-lab"
}

variable "alert_email" {
  description = "Email address for SNS alert notifications"
  type        = string
}