# SNS Topic - SOAR Alerts
resource "aws_sns_topic" "soar_alerts" {
  name         = "${var.project_name}-alerts"
  display_name = "SOAR Pipeline Alerts"

  tags = {
    Name        = "${var.project_name}-alerts"
    Environment = var.environment
    Project     = var.project_name
  }
}

# SNS Topic Policy - allow EC2 instances to publish
resource "aws_sns_topic_policy" "soar_alerts_policy" {
  arn = aws_sns_topic.soar_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEC2Publish"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.soar_role.arn
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.soar_alerts.arn
      },
      {
        Sid    = "AllowOwnerFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "sns:*"
        Resource = aws_sns_topic.soar_alerts.arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "soar_email_alert" {
  topic_arn = aws_sns_topic.soar_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarm - High severity Wazuh alerts via SNS
resource "aws_cloudwatch_metric_alarm" "high_severity_alerts" {
  alarm_name          = "${var.project_name}-high-severity-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HighSeverityAlerts"
  namespace           = "SOARPipeline"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Triggered when Wazuh detects high severity security alerts"
  alarm_actions       = [aws_sns_topic.soar_alerts.arn]
  ok_actions          = [aws_sns_topic.soar_alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = {
    Name        = "${var.project_name}-high-severity-alarm"
    Environment = var.environment
    Project     = var.project_name
  }
}