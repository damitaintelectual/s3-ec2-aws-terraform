terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Create a new S3 bucket with version & encryption enabled
resource "aws_s3_bucket" "terra_bucket1" {
  bucket = "my-terra-bucket-99"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "my-terra-bucket-99"
    Environment = "dev"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "bk-policy" {
  bucket = aws_s3_bucket.terra_bucket1.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}