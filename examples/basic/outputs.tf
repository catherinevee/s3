# Basic Example Outputs

output "bucket_name" {
  description = "The name of the created S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_domain_name" {
  description = "The domain name of the bucket"
  value       = module.s3_bucket.bucket_domain_name
}

output "bucket_versioning_status" {
  description = "The versioning status of the bucket"
  value       = module.s3_bucket.bucket_versioning_status
}

output "bucket_encryption_algorithm" {
  description = "The encryption algorithm used"
  value       = module.s3_bucket.bucket_encryption_algorithm
} 