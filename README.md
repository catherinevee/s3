# AWS S3 Bucket Terraform Module

Terraform module for creating AWS S3 buckets with security, compliance, and cost optimization features.

## Features

- Security by default with public access blocked and encryption enabled
- Versioning support for data protection
- Lifecycle management for automated object transitions
- CORS configuration for cross-origin resource sharing
- Static website hosting capabilities
- Event notifications for Lambda, SQS, and SNS
- Cross-region and same-region replication
- Intelligent tiering for cost optimization
- Object lock for WORM compliance
- Flexible ACL and ownership controls
- Monitoring outputs

## Usage

### Basic Bucket

```hcl
module "s3_bucket" {
  source = "./s3"

  bucket_name = "my-example-bucket"
  environment = "prod"
  purpose     = "data-storage"

  common_tags = {
    Project     = "MyProject"
    Owner       = "DevOps"
    CostCenter  = "IT"
  }
}
```

### Advanced Bucket with All Features

```hcl
module "s3_bucket" {
  source = "./s3"

  bucket_name = "my-advanced-bucket"
  environment = "prod"
  purpose     = "application-data"

  # Encryption
  encryption_algorithm = "aws:kms"
  kms_key_id          = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
  bucket_key_enabled  = true

  # Versioning and Object Lock
  enable_versioning = true
  object_lock_configuration = {
    rules = [{
      default_retention = {
        mode  = "GOVERNANCE"
        days  = 30
      }
    }]
  }

  # Lifecycle Rules
  lifecycle_rules = [
    {
      id     = "log-rotation"
      status = "Enabled"
      filter = {
        prefix = "logs/"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
    },
    {
      id     = "incomplete-multipart"
      status = "Enabled"
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  # CORS Configuration
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  # Website Configuration
  website_configuration = {
    index_document = "index.html"
    error_document = "error.html"
  }

  # Notification Configuration
  notification_configuration = {
    lambda_functions = [
      {
        lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "uploads/"
      }
    ]
    topics = [
      {
        topic_arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
        events    = ["s3:ObjectRemoved:*"]
      }
    ]
  }

  # Intelligent Tiering
  intelligent_tiering_configurations = [
    {
      id   = "cost-optimization"
      name = "Cost Optimization"
      tiering = [
        {
          access_tier = "DEEP_ARCHIVE_ACCESS"
          days        = 180
        }
      ]
    }
  ]

  # Bucket Policy
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::my-advanced-bucket/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::123456789012:distribution/E1234567890123"
          }
        }
      }
    ]
  })

  common_tags = {
    Project     = "MyProject"
    Environment = "Production"
    Owner       = "DevOps"
    CostCenter  = "IT"
    DataClass   = "Confidential"
  }
}
```

### Replication Configuration

```hcl
module "s3_bucket" {
  source = "./s3"

  bucket_name = "source-bucket"
  environment = "prod"

  # Replication Configuration
  replication_configuration = {
    role = "arn:aws:iam::123456789012:role/s3-replication-role"
    rules = [
      {
        id       = "cross-region-replication"
        status   = "Enabled"
        priority = 1
        filter = {
          prefix = "important-data/"
        }
        destination = {
          bucket             = "arn:aws:s3:::destination-bucket"
          storage_class      = "STANDARD"
          replica_kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
        }
        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            status = "Enabled"
          }
        }
      }
    ]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | S3 bucket name | `string` | n/a | yes |
| environment | Environment name | `string` | `"dev"` | no |
| purpose | Bucket purpose | `string` | `"storage"` | no |
| common_tags | Common resource tags | `map(string)` | `{}` | no |
| enable_versioning | Enable bucket versioning | `bool` | `true` | no |
| encryption_algorithm | Server-side encryption algorithm | `string` | `"AES256"` | no |
| kms_key_id | KMS master key ID | `string` | `null` | no |
| bucket_key_enabled | Enable bucket keys for SSE-KMS | `bool` | `false` | no |
| block_public_acls | Block public ACLs | `bool` | `true` | no |
| block_public_policy | Block public bucket policies | `bool` | `true` | no |
| ignore_public_acls | Ignore public ACLs | `bool` | `true` | no |
| restrict_public_buckets | Restrict public bucket policies | `bool` | `true` | no |
| object_ownership | Object ownership setting | `string` | `"BucketOwnerPreferred"` | no |
| acl | Canned ACL to apply | `string` | `null` | no |
| lifecycle_rules | Lifecycle rules | `list(object)` | `[]` | no |
| cors_rules | CORS rules | `list(object)` | `[]` | no |
| website_configuration | Website configuration | `object` | `null` | no |
| notification_configuration | Notification configuration | `object` | `null` | no |
| bucket_policy | Bucket policy JSON | `string` | `null` | no |
| replication_configuration | Replication configuration | `object` | `null` | no |
| intelligent_tiering_configurations | Intelligent tiering configs | `list(object)` | `[]` | no |
| object_lock_configuration | Object lock configuration | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | Bucket name |
| bucket_arn | Bucket ARN |
| bucket_domain_name | Bucket domain name |
| bucket_regional_domain_name | Bucket region-specific domain name |
| bucket_region | AWS region |
| bucket_website_endpoint | Website endpoint |
| bucket_website_domain | Website domain |
| bucket_versioning_status | Versioning state |
| bucket_encryption_algorithm | Encryption algorithm |
| bucket_kms_key_id | KMS key ID |
| bucket_key_enabled | Bucket keys enabled |
| bucket_public_access_block_configuration | Public access block config |
| bucket_ownership_controls | Ownership controls |
| bucket_acl | Canned ACL |
| bucket_lifecycle_configuration | Lifecycle configuration |
| bucket_cors_configuration | CORS configuration |
| bucket_notification_configuration | Notification configuration |
| bucket_policy | Bucket policy |
| bucket_replication_configuration | Replication configuration |
| bucket_intelligent_tiering_configurations | Intelligent tiering configs |
| bucket_object_lock_configuration | Object lock configuration |
| bucket_tags | Resource tags |

## Resource Architecture

This module creates the following AWS resources:

| Resource | Type | Purpose |
|----------|------|---------|
| `aws_s3_bucket.this` | S3 Bucket | Main S3 bucket |
| `aws_s3_bucket_versioning.this` | S3 Bucket Versioning | Versioning control |
| `aws_s3_bucket_server_side_encryption_configuration.this` | S3 Bucket Encryption | Server-side encryption |
| `aws_s3_bucket_public_access_block.this` | S3 Bucket Public Access Block | Public access control |
| `aws_s3_bucket_ownership_controls.this` | S3 Bucket Ownership Controls | Object ownership |
| `aws_s3_bucket_acl.this` | S3 Bucket ACL | Bucket ACL |
| `aws_s3_bucket_lifecycle_configuration.this` | S3 Bucket Lifecycle | Object lifecycle |
| `aws_s3_bucket_cors_configuration.this` | S3 Bucket CORS | CORS rules |
| `aws_s3_bucket_website_configuration.this` | S3 Bucket Website | Website hosting |
| `aws_s3_bucket_notification.this` | S3 Bucket Notification | Event notifications |
| `aws_s3_bucket_policy.this` | S3 Bucket Policy | Bucket policy |
| `aws_s3_bucket_replication_configuration.this` | S3 Bucket Replication | Replication |
| `aws_s3_bucket_intelligent_tiering_configuration.this` | S3 Bucket Intelligent Tiering | Cost optimization |
| `aws_s3_bucket_object_lock_configuration.this` | S3 Bucket Object Lock | WORM compliance |

## Security Best Practices

### Encryption
- Always enable server-side encryption (default: AES256)
- Use KMS keys for additional security when required
- Enable bucket keys for SSE-KMS to reduce API costs

### Access Control
- Block all public access by default
- Use bucket policies for fine-grained access control
- Implement proper IAM roles and policies

### Versioning and Object Lock
- Enable versioning for data protection
- Use object lock for compliance requirements
- Implement lifecycle policies for cost management

### Monitoring and Logging
- Enable access logging to track bucket usage
- Set up CloudTrail for API call monitoring
- Use CloudWatch metrics for performance monitoring

## Cost Optimization

### Lifecycle Policies
- Transition objects to cheaper storage classes
- Delete old versions and incomplete multipart uploads
- Use intelligent tiering for automatic cost optimization

### Storage Classes
- Use appropriate storage classes based on access patterns
- Consider S3 Intelligent Tiering for unknown access patterns
- Use S3 One Zone-IA for non-critical data

### Replication
- Only replicate necessary data
- Use appropriate storage classes in destination buckets
- Consider same-region replication for compliance

## Examples

See the `examples/` directory for additional usage examples:

- [Basic Bucket](./examples/basic/)
- [Website Hosting](./examples/website/)
- [Data Lake](./examples/data-lake/)
- [Backup Storage](./examples/backup/)
- [Log Storage](./examples/logs/)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check the [AWS S3 documentation](https://docs.aws.amazon.com/s3/)
- Review [Terraform AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)