
# -------------------------
# S3 deployment artifact bucket
# -------------------------
resource "aws_s3_bucket" "deployments" {
  bucket_prefix = "${var.project_name}-deploy-"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-deployments"
  })
}

resource "aws_s3_bucket_public_access_block" "deployments" {
  bucket = aws_s3_bucket.deployments.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "deployments" {
  bucket = aws_s3_bucket.deployments.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deployments" {
  bucket = aws_s3_bucket.deployments.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------
# S3 Gateway VPC Endpoint
# -------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Associate ONLY with the route table used by EC2 private subnets
  route_table_ids = [
    aws_route_table.private.id
  ]

  # Restrict the endpoint to the deployment bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.deployments.arn,
          "${aws_s3_bucket.deployments.arn}/*"
        ]
      }
    ]
  })
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-s3-endpoint"
  })
}
