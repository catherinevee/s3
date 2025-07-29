# S3 Data Lake Example
# This example demonstrates using S3 for data lake storage with lifecycle policies and intelligent tiering

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

module "s3_data_lake" {
  source = "../../"

  bucket_name = "my-data-lake-${random_string.bucket_suffix.result}"
  environment = "prod"
  purpose     = "data-lake"

  # Enhanced encryption for data lake
  encryption_algorithm = "aws:kms"
  bucket_key_enabled  = true

  # Comprehensive lifecycle rules for data lake
  lifecycle_rules = [
    {
      id     = "raw-data-transition"
      status = "Enabled"
      filter = {
        prefix = "raw/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      noncurrent_version_transitions = [
        {
          noncurrent_days = 30
          storage_class   = "STANDARD_IA"
        },
        {
          noncurrent_days = 90
          storage_class   = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        noncurrent_days = 2555
      }
    },
    {
      id     = "processed-data-transition"
      status = "Enabled"
      filter = {
        prefix = "processed/"
      }
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id     = "temp-data-expiration"
      status = "Enabled"
      filter = {
        prefix = "temp/"
      }
      expiration = {
        days = 7
      }
    },
    {
      id     = "incomplete-multipart-cleanup"
      status = "Enabled"
      abort_incomplete_multipart_upload_days = 1
    }
  ]

  # Intelligent tiering for cost optimization
  intelligent_tiering_configurations = [
    {
      id   = "general-purpose"
      name = "General Purpose"
      tiering = [
        {
          access_tier = "DEEP_ARCHIVE_ACCESS"
          days        = 180
        },
        {
          access_tier = "INTELLIGENT_TIERING"
          days        = 90
        }
      ]
    },
    {
      id   = "analytics-data"
      name = "Analytics Data"
      filter = {
        prefix = "analytics/"
      }
      tiering = [
        {
          access_tier = "DEEP_ARCHIVE_ACCESS"
          days        = 90
        }
      ]
    }
  ]

  # CORS for data lake access
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag", "x-amz-meta-custom-header"]
      max_age_seconds = 3000
    }
  ]

  # Object lock for compliance
  object_lock_configuration = {
    rules = [{
      default_retention = {
        mode  = "GOVERNANCE"
        days  = 30
      }
    }]
  }

  # Notification for data processing
  notification_configuration = {
    lambda_functions = [
      {
        lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:data-processing"
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "raw/"
      }
    ]
    topics = [
      {
        topic_arn = "arn:aws:sns:us-east-1:123456789012:data-lake-notifications"
        events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
      }
    ]
  }

  common_tags = {
    Project     = "DataLakeExample"
    Owner       = "Data Engineering"
    CostCenter  = "Analytics"
    Environment = "Production"
    DataClass   = "Confidential"
    Purpose     = "Data Lake Storage"
  }
}

# Random string to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Sample data lake folder structure
resource "aws_s3_object" "data_lake_structure" {
  for_each = toset([
    "raw/",
    "processed/",
    "analytics/",
    "temp/",
    "archive/"
  ])

  bucket = module.s3_data_lake.bucket_id
  key    = each.value
  source = "/dev/null"
} 