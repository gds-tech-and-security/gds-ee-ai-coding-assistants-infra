variable "enable_github_actions" {
  description = "Enable Github OIDC federation"
  type        = bool
  default     = false
}

variable "github_actions_provider_config" {
  description = <<EOD
    Configuration for github actions provider
    Requires `enable_github_actions` to be true

    `thumbprint_list` is optional. If not provided, it will be fetched automatically
  EOD
  type = object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = optional(list(string))
  })
  default = {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = [
      "sts.amazonaws.com"
    ]
    thumbprint_list = null
  }
}
