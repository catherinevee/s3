# S3 Bucket Module Variables

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be between 3 and 63 characters long, contain only lowercase letters, numbers, dots, and hyphens, and start and end with a letter or number."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "purpose" {
  description = "Purpose of the S3 bucket"
  type        = string
  default     = "storage"

  validation {
    condition     = length(var.purpose) > 0 && length(var.purpose) <= 50
    error_message = "Purpose must be between 1 and 50 characters."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "The server-side encryption algorithm to use"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_id" {
  description = "The KMS master key ID for encryption (required when encryption_algorithm is 'aws:kms')"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket"
  type        = string
  default     = "BucketOwnerPreferred"

  validation {
    condition     = contains(["BucketOwnerPreferred", "BucketOwnerEnforced", "ObjectWriter"], var.object_ownership)
    error_message = "Object ownership must be one of: BucketOwnerPreferred, BucketOwnerEnforced, ObjectWriter."
  }
}

variable "acl" {
  description = "The canned ACL to apply to the bucket"
  type        = string
  default     = null

  validation {
    condition     = var.acl == null || contains(["private", "public-read", "public-read-write", "aws-exec-read", "authenticated-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write"], var.acl)
    error_message = "ACL must be one of: private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write."
  }
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id      = string
    status  = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(list(object({
        key   = string
        value = string
      })))
    }))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })))
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }))
    abort_incomplete_multipart_upload_days = optional(number)
  }))
  default = []
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

variable "website_configuration" {
  description = "Website configuration for the bucket"
  type = object({
    index_document = optional(string)
    error_document = optional(string)
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
  })
  default = null
}

variable "notification_configuration" {
  description = "Notification configuration for the bucket"
  type = object({
    lambda_functions = optional(list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string)
      filter_suffix       = optional(string)
    })))
    queues = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
    topics = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })))
  })
  default = null
}

variable "bucket_policy" {
  description = "The bucket policy as a JSON string"
  type        = string
  default     = null
}

variable "replication_configuration" {
  description = "Replication configuration for the bucket"
  type = object({
    role = string
    rules = list(object({
      id       = string
      status   = string
      priority = optional(number)
      filter = optional(object({
        prefix = optional(string)
        tags   = optional(list(object({
          key   = string
          value = string
        })))
      }))
      destination = object({
        bucket        = string
        storage_class = optional(string)
        replica_kms_key_id = optional(string)
        access_control_translation = optional(object({
          owner = string
        }))
        encryption_configuration = optional(object({
          replica_kms_key_id = string
        }))
        metrics = optional(object({
          status = string
          event_threshold = optional(object({
            minutes = number
          }))
        }))
      })
      source_selection_criteria = optional(object({
        sse_kms_encrypted_objects = optional(object({
          status = string
        }))
      }))
      delete_marker_replication = optional(object({
        status = string
      }))
    }))
  })
  default = null
}

variable "intelligent_tiering_configurations" {
  description = "Intelligent tiering configurations for the bucket"
  type = list(object({
    id   = string
    name = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(list(object({
        key   = string
        value = string
      })))
    }))
    tiering = list(object({
      access_tier = string
      days        = number
    }))
  }))
  default = []
}

variable "object_lock_configuration" {
  description = "Object lock configuration for the bucket"
  type = object({
    rules = list(object({
      default_retention = object({
        mode  = string
        days  = optional(number)
        years = optional(number)
      })
    }))
  })
  default = null
} 