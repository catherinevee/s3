# Data Lake Example Outputs

output "data_lake_bucket_name" {
  description = "The name of the data lake bucket"
  value       = module.s3_data_lake.bucket_id
}

output "data_lake_bucket_arn" {
  description = "The ARN of the data lake bucket"
  value       = module.s3_data_lake.bucket_arn
}

output "data_lake_encryption_algorithm" {
  description = "The encryption algorithm used for the data lake"
  value       = module.s3_data_lake.bucket_encryption_algorithm
}

output "data_lake_versioning_status" {
  description = "The versioning status of the data lake bucket"
  value       = module.s3_data_lake.bucket_versioning_status
}

output "data_lake_lifecycle_configuration" {
  description = "The lifecycle configuration of the data lake bucket"
  value       = module.s3_data_lake.bucket_lifecycle_configuration
}

output "data_lake_intelligent_tiering_configurations" {
  description = "The intelligent tiering configurations of the data lake bucket"
  value       = module.s3_data_lake.bucket_intelligent_tiering_configurations
}

output "data_lake_object_lock_configuration" {
  description = "The object lock configuration of the data lake bucket"
  value       = module.s3_data_lake.bucket_object_lock_configuration
}

output "data_lake_notification_configuration" {
  description = "The notification configuration of the data lake bucket"
  value       = module.s3_data_lake.bucket_notification_configuration
} 