
# -------------------------
# S3 deployment artifact bucket
# -------------------------


resource "aws_s3_bucket" "file-storage" {
  bucket = "etlab-storage"

  tags = merge(local.common_tags, {
    Name = "etlab-storage"
  })
    # 1. Prevent S3 from emptying automatically on bucket deletion
  force_destroy = false 

  # 2. Block Terraform from running a destroy operation on this resource
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_versioning" "file-storage" {
  bucket = aws_s3_bucket.file-storage.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket" "tenants" {
  bucket = "etlab-tenants"

  tags = merge(local.common_tags, {
    Name = "etlab-tenants"
  })
    # 1. Prevent S3 from emptying automatically on bucket deletion
  force_destroy = false 

  # 2. Block Terraform from running a destroy operation on this resource
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_versioning" "tenants" {
  bucket = aws_s3_bucket.tenants.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "deployments" {
  bucket = "${var.project_name}-deployments"

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
        Sid       = "AllowSpecificBucketAccess"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject","s3:PutObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.deployments.arn,
          "${aws_s3_bucket.deployments.arn}/*",
              aws_s3_bucket.file-storage.arn,
          "${aws_s3_bucket.file-storage.arn}/*"
        ]
      }
    ]
  })
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-s3-endpoint"
  })
}

locals {
  protected_buckets = {
    "file-data"   = aws_s3_bucket.file-storage.id
    "tenants"  = aws_s3_bucket.tenants.id
    "deployments"    = aws_s3_bucket.deployments.id
  }
}


resource "aws_s3_bucket_policy" "deny_delete" {
    for_each = local.protected_buckets
  bucket = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyBucketDeletion"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource  = [
                    "arn:aws:s3:::${each.value}",
          "arn:aws:s3:::${each.value}/*"
                ]
      }
    ]
  })
}