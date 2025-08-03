# Terraform Native Tests for S3 Module

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Test variables
variables {
  bucket_name = "test-bucket-123"
  environment = "test"
  purpose     = "testing"
}

# Test basic S3 bucket creation
run "basic_s3_bucket_creation" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == var.bucket_name
    error_message = "Bucket name should match expected value"
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default"
  }
}

# Test security configurations
run "security_configurations" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public ACLs should be blocked by default"
  }

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Default encryption should be AES256"
  }

  assert {
    condition     = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership == "BucketOwnerPreferred"
    error_message = "Object ownership should be BucketOwnerPreferred by default"
  }
}

# Test outputs
run "output_validation" {
  command = plan

  assert {
    condition     = output.bucket_id == var.bucket_name
    error_message = "Bucket ID output should match bucket name"
  }

  assert {
    condition     = can(regex("^arn:aws:s3:::", output.bucket_arn))
    error_message = "Bucket ARN should be a valid S3 ARN"
  }
}

# Module configuration
module "s3_bucket" {
  source = "../"

  bucket_name = var.bucket_name
  environment = var.environment
  purpose     = var.purpose

  common_tags = {
    Project     = "TestProject"
    Owner       = "TestTeam"
    CostCenter  = "Test"
  }
} 