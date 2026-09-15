resource "aws_s3_bucket" "this" {
  bucket           = var.bucket
  bucket_namespace = var.namespace

  tags          = var.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.versioning_status != "" ? 1 : 0

  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.object_ownership != "" ? 1 : 0

  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  rule {
    default_retention {
      mode  = var.object_lock_configuration.mode
      days  = try(var.object_lock_configuration.days, null)
      years = try(var.object_lock_configuration.years, null)
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}

resource "aws_s3_bucket_logging" "this" {
  count = var.logging_bucket_prefix != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.this.id
  target_prefix = var.logging_bucket_prefix

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  #checkov:skip=CKV_AWS_300:S3 lifecycle configuration sets period for aborting failed uploads with modified variable 'abort_incomplete_multipart_upload_days'
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [] : [true]

        content {
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          noncurrent_days           = try(noncurrent_version_expiration.value.noncurrent_days, null)
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
        }
      }

      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.this
  ]
}
