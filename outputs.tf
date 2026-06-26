# Wazuh Outputs
output "wazuh_public_ip" {
  description = "Public IP address of the Wazuh SIEM instance"
  value       = aws_eip.wazuh_eip.public_ip
}

output "wazuh_dashboard_url" {
  description = "Wazuh Dashboard URL"
  value       = "https://${aws_eip.wazuh_eip.public_ip}"
}

output "wazuh_api_url" {
  description = "Wazuh API URL"
  value       = "https://${aws_eip.wazuh_eip.public_ip}:55000"
}

output "wazuh_ssh_command" {
  description = "SSH command to connect to Wazuh instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_eip.wazuh_eip.public_ip}"
}

# n8n Outputs
output "n8n_public_ip" {
  description = "Public IP address of the n8n SOAR instance"
  value       = aws_eip.n8n_eip.public_ip
}

output "n8n_dashboard_url" {
  description = "n8n Dashboard URL"
  value       = "http://${aws_eip.n8n_eip.public_ip}:5678"
}

output "n8n_ssh_command" {
  description = "SSH command to connect to n8n instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_eip.n8n_eip.public_ip}"
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the incident reports S3 bucket"
  value       = aws_s3_bucket.incident_reports.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the incident reports S3 bucket"
  value       = aws_s3_bucket.incident_reports.arn
}

# SNS Outputs
output "sns_topic_arn" {
  description = "ARN of the SOAR alerts SNS topic"
  value       = aws_sns_topic.soar_alerts.arn
}

# Summary
output "deployment_summary" {
  description = "Full deployment summary"
  value = <<-EOT
    ==========================================
    SOAR PIPELINE DEPLOYMENT SUMMARY
    ==========================================
    Wazuh SIEM:
      - Dashboard : https://${aws_eip.wazuh_eip.public_ip}
      - API       : https://${aws_eip.wazuh_eip.public_ip}:55000
      - SSH       : ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_eip.wazuh_eip.public_ip}

    n8n SOAR:
      - Dashboard : http://${aws_eip.n8n_eip.public_ip}:5678
      - SSH       : ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_eip.n8n_eip.public_ip}

    Storage:
      - S3 Bucket : ${aws_s3_bucket.incident_reports.bucket}
      - SNS Topic : ${aws_sns_topic.soar_alerts.arn}
    ==========================================
  EOT
}