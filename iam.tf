# IAM Role for EC2 instances
resource "aws_iam_role" "soar_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Policy - S3 Incident Reports Access
resource "aws_iam_policy" "soar_s3_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow EC2 instances to write incident reports to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# IAM Policy - SNS Alert Publishing
resource "aws_iam_policy" "soar_sns_policy" {
  name        = "${var.project_name}-sns-policy"
  description = "Allow EC2 instances to publish alerts to SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.soar_alerts.arn
      }
    ]
  })
}

# IAM Policy - CloudWatch Logging
resource "aws_iam_policy" "soar_cloudwatch_policy" {
  name        = "${var.project_name}-cloudwatch-policy"
  description = "Allow EC2 instances to send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach Policies to Role
resource "aws_iam_role_policy_attachment" "soar_s3_attach" {
  role       = aws_iam_role.soar_role.name
  policy_arn = aws_iam_policy.soar_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "soar_sns_attach" {
  role       = aws_iam_role.soar_role.name
  policy_arn = aws_iam_policy.soar_sns_policy.arn
}

resource "aws_iam_role_policy_attachment" "soar_cloudwatch_attach" {
  role       = aws_iam_role.soar_role.name
  policy_arn = aws_iam_policy.soar_cloudwatch_policy.arn
}

# SSM Policy for remote management (no SSH needed as backup)
resource "aws_iam_role_policy_attachment" "soar_ssm_attach" {
  role       = aws_iam_role.soar_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "soar_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.soar_role.name

  tags = {
    Name        = "${var.project_name}-ec2-profile"
    Environment = var.environment
    Project     = var.project_name
  }
}