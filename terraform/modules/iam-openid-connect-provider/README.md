# iam-openid-connect-provider

Configures OIDC providers.

Supported:

- `github_actions`

## Usage

Configure Github OIDC provider (only one per AWS account):

```hcl
module "iam_openid_connect_provider" {
  source = "..."

  enable_github_actions = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enable_github_actions"></a> [enable\_github\_actions](#input\_enable\_github\_actions) | Enable Github OIDC federation | `bool` | `false` | no |
| <a name="input_github_actions_provider_config"></a> [github\_actions\_provider\_config](#input\_github\_actions\_provider\_config) | Configuration for github actions provider<br/>    Requires `enable_github_actions` to be true<br/><br/>    `thumbprint_list` is optional. If not provided, it will be fetched automatically | <pre>object({<br/>    url             = string<br/>    client_id_list  = list(string)<br/>    thumbprint_list = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "client_id_list": [<br/>    "sts.amazonaws.com"<br/>  ],<br/>  "thumbprint_list": null,<br/>  "url": "https://token.actions.githubusercontent.com"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
