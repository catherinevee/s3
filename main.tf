# S3 Bucket Module
# This module creates an S3 bucket with security and lifecycle configurations

# Data source for current region
data "aws_region" "current" {}

# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = var.prevent_destroy
  }

  tags = local.computed_tags
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server Side Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encryption_algorithm
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "this" {
  count  = var.acl != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_ownership_controls.this
  ]
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions != null ? rule.value.noncurrent_version_transitions : []
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_upload_days] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website_configuration.index_document != null ? [var.website_configuration.index_document] : []
    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = var.website_configuration.error_document != null ? [var.website_configuration.error_document] : []
    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_configuration.redirect_all_requests_to != null ? [var.website_configuration.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "this" {
  count  = var.notification_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "lambda_function" {
    for_each = var.notification_configuration.lambda_functions != null ? var.notification_configuration.lambda_functions : []
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.notification_configuration.queues != null ? var.notification_configuration.queues : []
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = var.notification_configuration.topics != null ? var.notification_configuration.topics : []
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# S3 Bucket Replication Configuration
resource "aws_s3_bucket_replication_configuration" "this" {
  count  = var.replication_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  role   = var.replication_configuration.role

  dynamic "rule" {
    for_each = var.replication_configuration.rules
    content {
      id       = rule.value.id
      status   = rule.value.status
      priority = rule.value.priority

      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }

      dynamic "destination" {
        for_each = rule.value.destination != null ? [rule.value.destination] : []
        content {
          bucket             = destination.value.bucket
          storage_class      = destination.value.storage_class
          replica_kms_key_id = destination.value.replica_kms_key_id

          dynamic "access_control_translation" {
            for_each = destination.value.access_control_translation != null ? [destination.value.access_control_translation] : []
            content {
              owner = access_control_translation.value.owner
            }
          }

          dynamic "encryption_configuration" {
            for_each = destination.value.encryption_configuration != null ? [destination.value.encryption_configuration] : []
            content {
              replica_kms_key_id = encryption_configuration.value.replica_kms_key_id
            }
          }

          dynamic "metrics" {
            for_each = destination.value.metrics != null ? [destination.value.metrics] : []
            content {
              status = metrics.value.status

              dynamic "event_threshold" {
                for_each = metrics.value.event_threshold != null ? [metrics.value.event_threshold] : []
                content {
                  minutes = event_threshold.value.minutes
                }
              }
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []
        content {
          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }

      dynamic "delete_marker_replication" {
        for_each = rule.value.delete_marker_replication != null ? [rule.value.delete_marker_replication] : []
        content {
          status = delete_marker_replication.value.status
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

# S3 Bucket Intelligent Tiering Configuration
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = { for idx, config in var.intelligent_tiering_configurations : config.id => config }
  
  bucket = aws_s3_bucket.this.id
  name   = each.value.name

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []
    content {
      prefix = filter.value.prefix

      dynamic "tag" {
        for_each = filter.value.tags != null ? filter.value.tags : []
        content {
          key   = tag.value.key
          value = tag.value.value
        }
      }
    }
  }

  dynamic "tiering" {
    for_each = each.value.tiering
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}

# S3 Bucket Object Lock Configuration
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = var.object_lock_configuration != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.object_lock_configuration.rules != null ? var.object_lock_configuration.rules : []
    content {
      default_retention {
        mode  = rule.value.default_retention.mode
        days  = rule.value.default_retention.days
        years = rule.value.default_retention.years
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
} 