# Basic S3 Bucket Example
# This example demonstrates the simplest usage of the S3 module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "my-basic-bucket-${random_string.bucket_suffix.result}"
  environment = "dev"
  purpose     = "basic-storage"

  common_tags = {
    Project     = "BasicExample"
    Owner       = "DevOps"
    CostCenter  = "IT"
    Environment = "Development"
  }
}

# Random string to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
} 