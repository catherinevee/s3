# AWS S3 Bucket Terraform Module

A comprehensive Terraform module for creating AWS S3 buckets with advanced configurations including encryption, versioning, lifecycle policies, CORS, website hosting, and more.

## Features

- ✅ **Security by Default**: Public access blocked, encryption enabled
- ✅ **Versioning Support**: Configurable bucket versioning
- ✅ **Lifecycle Management**: Automated object transitions and expiration
- ✅ **CORS Configuration**: Cross-origin resource sharing support
- ✅ **Website Hosting**: Static website hosting capabilities
- ✅ **Event Notifications**: Lambda, SQS, and SNS notifications
- ✅ **Replication**: Cross-region and same-region replication
- ✅ **Intelligent Tiering**: Cost optimization with automatic tiering
- ✅ **Object Lock**: WORM (Write Once Read Many) compliance
- ✅ **Access Control**: Flexible ACL and ownership controls
- ✅ **Monitoring**: Comprehensive outputs for monitoring

## Usage

### Basic Usage

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

### Advanced Usage with All Features

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

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | The name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| purpose | Purpose of the S3 bucket | `string` | `"storage"` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |
| enable_versioning | Enable versioning for the S3 bucket | `bool` | `true` | no |
| encryption_algorithm | The server-side encryption algorithm to use | `string` | `"AES256"` | no |
| kms_key_id | The KMS master key ID for encryption | `string` | `null` | no |
| bucket_key_enabled | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS | `bool` | `false` | no |
| block_public_acls | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| block_public_policy | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| ignore_public_acls | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| restrict_public_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| object_ownership | Object ownership setting for the bucket | `string` | `"BucketOwnerPreferred"` | no |
| acl | The canned ACL to apply to the bucket | `string` | `null` | no |
| lifecycle_rules | List of lifecycle rules for the bucket | `list(object)` | `[]` | no |
| cors_rules | List of CORS rules for the bucket | `list(object)` | `[]` | no |
| website_configuration | Website configuration for the bucket | `object` | `null` | no |
| notification_configuration | Notification configuration for the bucket | `object` | `null` | no |
| bucket_policy | The bucket policy as a JSON string | `string` | `null` | no |
| replication_configuration | Replication configuration for the bucket | `object` | `null` | no |
| intelligent_tiering_configurations | Intelligent tiering configurations for the bucket | `list(object)` | `[]` | no |
| object_lock_configuration | Object lock configuration for the bucket | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket region-specific domain name |
| bucket_region | The AWS region this bucket resides in |
| bucket_website_endpoint | The website endpoint, if the bucket is configured with a website |
| bucket_website_domain | The domain of the website endpoint, if the bucket is configured with a website |
| bucket_versioning_status | The versioning state of the bucket |
| bucket_encryption_algorithm | The server-side encryption algorithm used |
| bucket_kms_key_id | The KMS key ID used for encryption |
| bucket_key_enabled | Whether bucket keys are enabled for SSE-KMS |
| bucket_public_access_block_configuration | The public access block configuration |
| bucket_ownership_controls | The bucket ownership controls |
| bucket_acl | The canned ACL applied to the bucket |
| bucket_lifecycle_configuration | The lifecycle configuration of the bucket |
| bucket_cors_configuration | The CORS configuration of the bucket |
| bucket_notification_configuration | The notification configuration of the bucket |
| bucket_policy | The bucket policy |
| bucket_replication_configuration | The replication configuration of the bucket |
| bucket_intelligent_tiering_configurations | The intelligent tiering configurations of the bucket |
| bucket_object_lock_configuration | The object lock configuration of the bucket |
| bucket_tags | A mapping of tags assigned to the bucket |

## Resource Map

This module creates the following AWS resources:

| Resource | Type | Purpose |
|----------|------|---------|
| `aws_s3_bucket.this` | S3 Bucket | Main S3 bucket resource |
| `aws_s3_bucket_versioning.this` | S3 Bucket Versioning | Enables/disables versioning |
| `aws_s3_bucket_server_side_encryption_configuration.this` | S3 Bucket Encryption | Configures server-side encryption |
| `aws_s3_bucket_public_access_block.this` | S3 Bucket Public Access Block | Blocks public access |
| `aws_s3_bucket_ownership_controls.this` | S3 Bucket Ownership Controls | Sets object ownership |
| `aws_s3_bucket_acl.this` | S3 Bucket ACL | Sets bucket ACL (conditional) |
| `aws_s3_bucket_lifecycle_configuration.this` | S3 Bucket Lifecycle | Manages object lifecycle (conditional) |
| `aws_s3_bucket_cors_configuration.this` | S3 Bucket CORS | Configures CORS rules (conditional) |
| `aws_s3_bucket_website_configuration.this` | S3 Bucket Website | Configures website hosting (conditional) |
| `aws_s3_bucket_notification.this` | S3 Bucket Notification | Sets up event notifications (conditional) |
| `aws_s3_bucket_policy.this` | S3 Bucket Policy | Applies bucket policy (conditional) |
| `aws_s3_bucket_replication_configuration.this` | S3 Bucket Replication | Configures replication (conditional) |
| `aws_s3_bucket_intelligent_tiering_configuration.this` | S3 Bucket Intelligent Tiering | Sets up intelligent tiering (conditional) |
| `aws_s3_bucket_object_lock_configuration.this` | S3 Bucket Object Lock | Configures object lock (conditional) |

## Security Best Practices

### 1. Encryption
- Always enable server-side encryption (default: AES256)
- Use KMS keys for additional security when required
- Enable bucket keys for SSE-KMS to reduce API costs

### 2. Access Control
- Block all public access by default
- Use bucket policies for fine-grained access control
- Implement proper IAM roles and policies

### 3. Versioning and Object Lock
- Enable versioning for data protection
- Use object lock for compliance requirements
- Implement lifecycle policies for cost management

### 4. Monitoring and Logging
- Enable access logging to track bucket usage
- Set up CloudTrail for API call monitoring
- Use CloudWatch metrics for performance monitoring

## Cost Optimization

### 1. Lifecycle Policies
- Transition objects to cheaper storage classes
- Delete old versions and incomplete multipart uploads
- Use intelligent tiering for automatic cost optimization

### 2. Storage Classes
- Use appropriate storage classes based on access patterns
- Consider S3 Intelligent Tiering for unknown access patterns
- Use S3 One Zone-IA for non-critical data

### 3. Replication
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

This module is licensed under the MIT License. See LICENSE for full details.

## Support

For issues and questions:
- Create an issue in the repository
- Check the [AWS S3 documentation](https://docs.aws.amazon.com/s3/)
- Review [Terraform AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)