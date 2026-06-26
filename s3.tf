# S3 Bucket - Incident Reports
resource "aws_s3_bucket" "incident_reports" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "incident_reports_block" {
  bucket                  = aws_s3_bucket.incident_reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "incident_reports_versioning" {
  bucket = aws_s3_bucket.incident_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "incident_reports_encryption" {
  bucket = aws_s3_bucket.incident_reports.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "incident_reports_lifecycle" {
  bucket = aws_s3_bucket.incident_reports.id
  rule {
    id     = "incident-reports-lifecycle"
    status = "Enabled"
    filter {
      prefix = ""
    }
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_policy" "incident_reports_policy" {
  bucket = aws_s3_bucket.incident_reports.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonSSL"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.incident_reports_block]
}