###########
# Required
###########
variable "bucket" {
  description = "The name of the S3 bucket"
  type        = string
}

###########
# Optional
###########
variable "force_destroy" {
  description = "Destroy S3 bucket even if it isn't empty"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Namespace for the bucket. Determines bucket naming scope. Valid values: account-regional, global. Defaults to global (AWS)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "minimum_tls_version" {
  description = "The minimum TLS version that is desired to access objects in the bucket"
  type        = string
  default     = "1.3"
}

variable "attach_policy" {
  description = "(Optional) A flag to determine whether to attach a bucket policy. This must be set to true if minimum_tls_version is specified or deny_insecure_transport is set to true"
  type        = bool
  default     = true
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "deny_insecure_transport" {
  description = "Deny insecure transport (HTTP)"
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "The object ownership setting"
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "versioning_status" {
  description = "Enable versioning on the S3 bucket"
  type        = string
  default     = "Enabled"
}

variable "enable_encryption" {
  description = "Enable server-side encryption on the S3 bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "The KMS key ID to use for encryption"
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "value"
  type        = bool
  default     = true
}
variable "block_public_policy" {
  description = "value"
  type        = bool
  default     = true
}
variable "ignore_public_acls" {
  description = "value"
  type        = bool
  default     = true
}
variable "restrict_public_buckets" {
  description = "value"
  type        = bool
  default     = true
}

variable "object_lock_configuration" {
  description = "Map containing S3 object locking configuration"
  type        = any
  default = {
    mode = "COMPLIANCE"
    days = 30
  }
}

variable "logging_bucket_prefix" {
  description = "Prefix to store access bucket logging"
  type        = any
  default     = null
}

variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management"
  type        = any
  default     = []
}
