variable "gds_cidrs_list" {
  description = "ip ranges we allow to assume this role"
  # https://sites.google.com/a/digital.cabinet-office.gov.uk/gds/working-at-gds/gds-internal-it/gds-internal-it-network-public-ip-addresses
  # https://docs.google.com/document/d/1eSBNvLXA0RlcKwkvvf4fbg9XF7KYMn_MAZ59q49Y-S4/edit?tab=t.0#heading=h.rg8thign5876
  default = [
    "159.254.101.107/32",
    "159.254.101.75/32",
    "164.137.3.121/32",
    "164.137.3.89/32",
    "217.196.229.77/32",
    "217.196.229.79/32",
    "217.196.229.80/32",
    "217.196.229.81/32",
    "51.149.8.0/25",
    "51.149.8.128/29"
  ]
  type = list(string)
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
    read-only = []
  }
}

variable "role_assuming_account_id" {
  description = "The account id in which resides the users we're allowing to assume this role"
  default     = "622626885786"
  type        = string
}
