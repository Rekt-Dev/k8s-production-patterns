terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ── S3 bucket for Terraform state ────────────────────────────────────────────
resource "aws_s3_bucket" "tfstate" {
  bucket = "your-tfstate-bucket"
  tags   = { ManagedBy = "terraform", Purpose = "terraform-state" }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tfstate.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── DynamoDB for state locking ────────────────────────────────────────────────
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tfstate.arn
  }

  tags = { ManagedBy = "terraform", Purpose = "terraform-state-lock" }
}

# ── KMS key for state encryption ─────────────────────────────────────────────
resource "aws_kms_key" "tfstate" {
  description             = "Terraform state encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "tfstate" {
  name          = "alias/terraform-state"
  target_key_id = aws_kms_key.tfstate.key_id
}
