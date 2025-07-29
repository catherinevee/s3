# S3 Website Hosting Example
# This example demonstrates using S3 for static website hosting

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

module "s3_website" {
  source = "../../"

  bucket_name = "my-website-bucket-${random_string.bucket_suffix.result}"
  environment = "prod"
  purpose     = "website-hosting"

  # Website Configuration
  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

  # CORS Configuration for web applications
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  # Lifecycle rules for website optimization
  lifecycle_rules = [
    {
      id     = "website-optimization"
      status = "Enabled"
      filter = {
        prefix = ""
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]
    },
    {
      id     = "incomplete-multipart"
      status = "Enabled"
      abort_incomplete_multipart_upload_days = 1
    }
  ]

  # Bucket policy to allow public read access for website hosting
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::my-website-bucket-${random_string.bucket_suffix.result}/*"
      }
    ]
  })

  # Override public access settings for website hosting
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  common_tags = {
    Project     = "WebsiteExample"
    Owner       = "DevOps"
    CostCenter  = "Marketing"
    Environment = "Production"
    Purpose     = "Static Website"
  }
}

# Random string to ensure unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Sample website files
resource "aws_s3_object" "index_html" {
  bucket       = module.s3_website.bucket_id
  key          = "index.html"
  content      = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
</head>
<body>
    <h1>Hello from S3!</h1>
    <p>This is a static website hosted on Amazon S3.</p>
</body>
</html>
EOF
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket       = module.s3_website.bucket_id
  key          = "error.html"
  content      = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Error - Page Not Found</title>
</head>
<body>
    <h1>404 - Page Not Found</h1>
    <p>The page you are looking for does not exist.</p>
    <a href="/">Go back to homepage</a>
</body>
</html>
EOF
  content_type = "text/html"
} 