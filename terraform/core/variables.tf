variable "environment" {
  description = "The environment name"
  type        = string
}

variable "state_bucket_name" {
  description = "State bucket name"
  type        = string
}

variable "users_roles" {
  description = <<EOD
    Map of IAM users grouped by role. Each role is assigned a default policy, and contain a list of users who can assume the role.
    Users must exist in the gds-users AWS account to be valid.
      E.g. first.lastname@digital.cabinet-office.gov.uk
  EOD
  type        = map(list(string))
  default = {
    admin     = []
    read_only = []
  }
}

variable "deployment_pipeline_oidc_subjects" {
  description = "List of IAM roles with subject claims used for the deployment pipelines"
  type        = map(list(string))
  default     = {}
}
