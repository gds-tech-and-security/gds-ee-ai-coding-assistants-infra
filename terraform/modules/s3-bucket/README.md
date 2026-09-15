# AWS S3 Bucket Terraform Module

Creates an S3 bucket with secure default policies.

## Usage

### Simple bucket

```hcl
module "s3_bucket" {
  source = "..."

  bucket = "myorg-myaccount-tfstate"

  # Optional
  namespace = "mynamespace"
}
```

### Bucket with policy

```hcl
data "aws_iam_policy_document" "billing_bucket_policy" {
  statement {
    sid    = "AllowCURPutObject"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "billingreports.amazonaws.com",
        "bcm-data-exports.amazonaws.com"
      ]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.billing_bucket_name}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.id]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.id}:definition/*",
        "arn:aws:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.id}:export/*"
      ]
    }
  }
}

module "s3_bucket" {
  source = "..."

  bucket = "myorg-myaccount-tfstate"

  policy = data.aws_iam_policy_document.billing_bucket_policy.json
}
```

### Bucket with lifecycle rules

```hcl
locals {
  s3_logging_prefix = "s3-access-logs"
}

module "s3_bucket_state" {
  source = "..."

  bucket = "myorg-myaccount-tfstate"

  logging_bucket_prefix = local.s3_logging_prefix

  lifecycle_rules = [
    {
      id                                     = "tfstate"
      status                                 = "Enabled"
      abort_incomplete_multipart_upload_days = 1
      noncurrent_version_expiration = {
        noncurrent_days           = 14
        newer_noncurrent_versions = 5
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
```

### Bucket with custom object lock configuration

```hcl
module "s3_state" {
  source = "..."

  bucket = "myorg-myaccount-tfstate"

  object_lock_configuration = {
    mode = "COMPLIANCE"
    days = 90
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the S3 bucket | `string` | n/a | yes |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | (Optional) A flag to determine whether to attach a bucket policy. This must be set to true if minimum\_tls\_version is specified or deny\_insecure\_transport is set to true | `bool` | `true` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | value | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | value | `bool` | `true` | no |
| <a name="input_deny_insecure_transport"></a> [deny\_insecure\_transport](#input\_deny\_insecure\_transport) | Deny insecure transport (HTTP) | `bool` | `true` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable server-side encryption on the S3 bucket | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Destroy S3 bucket even if it isn't empty | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | value | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key ID to use for encryption | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management | `any` | `[]` | no |
| <a name="input_logging_bucket_prefix"></a> [logging\_bucket\_prefix](#input\_logging\_bucket\_prefix) | Prefix to store access bucket logging | `any` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version that is desired to access objects in the bucket | `string` | `"1.3"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the bucket. Determines bucket naming scope. Valid values: account-regional, global. Defaults to global (AWS) | `string` | `null` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Map containing S3 object locking configuration | `any` | <pre>{<br/>  "days": 30,<br/>  "mode": "COMPLIANCE"<br/>}</pre> | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | The object ownership setting | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | value | `bool` | `true` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | Server-side encryption algorithm | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to the bucket. | `map(string)` | `{}` | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | Enable versioning on the S3 bucket | `string` | `"Enabled"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | Region where the bucket lives |
<!-- END_TF_DOCS -->
