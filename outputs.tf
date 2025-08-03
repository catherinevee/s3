# S3 Bucket Module Outputs

output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_region" {
  description = "The AWS region this bucket resides in"
  value       = aws_s3_bucket.this.region
}

output "bucket_url" {
  description = "The URL of the bucket"
  value       = local.bucket_url
}

output "bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = try(aws_s3_bucket_website_configuration.this[0].website_endpoint, null)
}

output "bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website"
  value       = try(aws_s3_bucket_website_configuration.this[0].website_domain, null)
}

output "bucket_website_redirect_all_requests_to" {
  description = "The redirect_all_requests_to argument of the bucket"
  value       = try(aws_s3_bucket_website_configuration.this[0].redirect_all_requests_to, null)
}

output "bucket_website_routing_rules" {
  description = "The routing_rules argument of the bucket"
  value       = try(aws_s3_bucket_website_configuration.this[0].routing_rules, null)
}

output "bucket_versioning_status" {
  description = "The versioning state of the bucket"
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}

output "bucket_encryption_algorithm" {
  description = "The server-side encryption algorithm used"
  value       = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm
}

output "bucket_kms_key_id" {
  description = "The KMS key ID used for encryption"
  value       = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].kms_master_key_id
  sensitive   = true
}

output "bucket_key_enabled" {
  description = "Whether bucket keys are enabled for SSE-KMS"
  value       = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].bucket_key_enabled
}

output "bucket_public_access_block_configuration" {
  description = "The public access block configuration"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.this.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.this.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.this.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.this.restrict_public_buckets
  }
}

output "bucket_ownership_controls" {
  description = "The bucket ownership controls"
  value       = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership
}

output "bucket_acl" {
  description = "The canned ACL applied to the bucket"
  value       = try(aws_s3_bucket_acl.this[0].acl, null)
}

output "bucket_lifecycle_configuration" {
  description = "The lifecycle configuration of the bucket"
  value       = try(aws_s3_bucket_lifecycle_configuration.this[0].rule, [])
}

output "bucket_cors_configuration" {
  description = "The CORS configuration of the bucket"
  value       = try(aws_s3_bucket_cors_configuration.this[0].cors_rule, [])
}

output "bucket_notification_configuration" {
  description = "The notification configuration of the bucket"
  value = {
    lambda_functions = try(aws_s3_bucket_notification.this[0].lambda_function, [])
    queues           = try(aws_s3_bucket_notification.this[0].queue, [])
    topics           = try(aws_s3_bucket_notification.this[0].topic, [])
  }
}

output "bucket_policy" {
  description = "The bucket policy"
  value       = try(aws_s3_bucket_policy.this[0].policy, null)
}

output "bucket_replication_configuration" {
  description = "The replication configuration of the bucket"
  value       = try(aws_s3_bucket_replication_configuration.this[0].rule, [])
}

output "bucket_intelligent_tiering_configurations" {
  description = "The intelligent tiering configurations of the bucket"
  value       = [for config in aws_s3_bucket_intelligent_tiering_configuration.this : {
    id   = config.id
    name = config.name
  }]
}

output "bucket_object_lock_configuration" {
  description = "The object lock configuration of the bucket"
  value       = try(aws_s3_bucket_object_lock_configuration.this[0].rule, [])
}

output "bucket_tags" {
  description = "A mapping of tags assigned to the bucket"
  value       = aws_s3_bucket.this.tags
} 