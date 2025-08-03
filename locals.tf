# Local values for S3 Bucket Module

locals {
  # Common tags with computed values
  computed_tags = merge(
    var.common_tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
      Purpose     = var.purpose
      ManagedBy   = "Terraform"
      Module      = "terraform-aws-s3"
    }
  )

  # Validation helpers
  is_kms_encryption = var.encryption_algorithm == "aws:kms"
  requires_kms_key  = local.is_kms_encryption && var.kms_key_id == null

  # Computed values for outputs
  bucket_url = "https://${aws_s3_bucket.this.bucket}.s3.${data.aws_region.current.name}.amazonaws.com"
} 