# Website Example Outputs

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = module.s3_website.bucket_website_endpoint
}

output "website_domain" {
  description = "The website domain"
  value       = module.s3_website.bucket_website_domain
}

output "bucket_name" {
  description = "The name of the website bucket"
  value       = module.s3_website.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the website bucket"
  value       = module.s3_website.bucket_arn
}

output "website_url" {
  description = "The complete website URL"
  value       = "http://${module.s3_website.bucket_website_endpoint}"
} 