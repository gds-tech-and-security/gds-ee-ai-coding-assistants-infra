locals {
  s3_logging_prefix = "s3-logs"
}

module "s3_state" {
  #checkov:skip=CKV2_AWS_62:Event notifications are not particularly useful for terraform state files
  #checkov:skip=CKV_AWS_144:TODO
  #checkov:skip=CKV_AWS_145:TODO
  source = "../modules/s3-bucket"

  bucket                = var.state_bucket_name
  logging_bucket_prefix = local.s3_logging_prefix

  lifecycle_rules = [
    {
      id                                     = "tfstate"
      status                                 = "Enabled"
      abort_incomplete_multipart_upload_days = 1
      noncurrent_version_expiration = {
        noncurrent_days = 14
      }
    },
    {
      id                                     = local.s3_logging_prefix
      status                                 = "Enabled"
      abort_incomplete_multipart_upload_days = 1
      filter = {
        prefix = "${local.s3_logging_prefix}/"
      }
      expiration = {
        days = 365
      }
    }
  ]
}
