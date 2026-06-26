# SOC SOAR Pipeline Lab
Automated SOC triage pipeline built with Terraform on AWS.

## Architecture
- Wazuh SIEM (EC2 t3.medium) - Alert detection and log analysis
- n8n SOAR (EC2 t3.small) - Automated triage workflows
- S3 - Encrypted incident report storage (AES-256)
- SNS - Real-time alert notifications
- CloudWatch - High severity alarm monitoring
- IAM - Least-privilege roles and policies

## Tools & Technologies
Terraform, AWS, Wazuh, n8n, Docker, IAM, S3, SNS, CloudWatch

## Usage
1. Clone the repo
2. Create terraform.tfvars with your values
3. Run terraform init
4. Run terraform apply
