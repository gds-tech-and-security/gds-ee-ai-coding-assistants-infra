# AWS IAM Role Terraform Module

Creates a single IAM role which can be assumed by trusted resources.

## Usage

### [IAM Role - GitHub Free, Pro, & Team OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

The defaults provided by the module are suitable for GitHub Free, Pro, & Team, including use with the official [AWS GitHub action](https://github.com/aws-actions/configure-aws-credentials).

```hcl
module "iam_role" {
  source = "..."

  enable_github_oidc = true

  # This should be updated to suit your organization, repository, references/branches, etc.
  oidc_wildcard_subjects = ["terraform-aws-modules/terraform-aws-iam:*"]

  attach_policies = {
    S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = {
    Environment = "test"
  }
}
```

### [IAM Role - GitHub Enterprise Server OIDC](https://docs.github.com/en/enterprise-server@3.7/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

For GitHub Enterprise Server, users will need to provide value for the `oidc_audience` and `provider_urls` to suit their `<GITHUB_ORG>` installation:

```hcl
module "iam_role" {
  source = "..."

  enable_github_oidc = true

  oidc_audiences     = ["https://mygithub.com/<GITHUB_ORG>"]
  oidc_provider_urls = ["mygithub.com/_services/token"]

  # This should be updated to suit your organization, repository, references/branches, etc.
  oidc_wildcard_subjects = ["<GITHUB_ORG>/terraform-aws-iam:*"]

  attach_policies = {
    S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = {
    Environment = "test"
  }
}
```

### IAM Role - User assume

```hcl
module "iam_role" {
  source  = "..."

  name = "example"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      principals = [{
        type = "AWS"
        identifiers = [
          "arn:aws:iam::835367859851:user/anton",
        ]
      }]
      condition = [{
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = ["some-secret-id"]
      }]
    }
  }

  attach_policies = {
    S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### IAM Role - SAML 2.0

Creates an IAM role that trusts a SAML provider. Useful for trusting external identity providers such as Okta, OneLogin, etc.

[Creating IAM SAML Identity Providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_saml.html)
[Enabling SAML 2.0 Federated Users to Access the AWS Management Console](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-saml.html)

```hcl
module "iam_role" {
  source  = "..."

  enable_saml       = true
  saml_provider_ids = ["arn:aws:iam::235367859851:saml-provider/idp_saml"]

  attach_policies = {
    ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Policies - Attach

Creates a role and attach existing policies (default or custom).

```hcl
module "iam_role" {
  source = "..."

  name = "example"

  attach_policies = {
    ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess",
    ...
  }
}
```

## Policies - JSON Policy Document

```hcl
data "aws_iam_policy_document" "management" {
  statement {
    sid    = "AllowManageIAMRolesAndPolicies"
    effect = "Allow"
    actions = [
      "iam:*",
    ]
    resources = [
      "*"
    ]
  }
}

module "iam_role" {
  source = "..."

  name = "example"

  json_policy_documents = [
    data.aws_iam_policy_document.management.json,
    ...
  ]
}
```

## Policies - Inline

Creates a role with inline policy. Each map key name becomes the SID.

```hcl
module "iam_role" {
  source = "..."

  name = "example"

  inline_policy_permissions = {
    AllowManageIAMRolesAndPolicies = {
      effect = "Allow"
      actions = [
        "iam:*",
      ]
      resources = ["*"]
    },
    ...
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_attach_policies"></a> [attach\_policies](#input\_attach\_policies) | Existing policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the role | `string` | `null` | no |
| <a name="input_enable_github_oidc"></a> [enable\_github\_oidc](#input\_enable\_github\_oidc) | Enable GitHub OIDC provider trust for the role | `bool` | `false` | no |
| <a name="input_enable_oidc"></a> [enable\_oidc](#input\_enable\_oidc) | Enable OIDC provider trust for the role | `bool` | `false` | no |
| <a name="input_enable_saml"></a> [enable\_saml](#input\_enable\_saml) | Enable SAML provider trust for the role | `bool` | `false` | no |
| <a name="input_github_provider"></a> [github\_provider](#input\_github\_provider) | The GitHub OIDC provider URL *without the `https://` prefix | `string` | `"token.actions.githubusercontent.com"` | no |
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | INCOMPATIBLE with 'json\_policy\_documents'. Use one or the other<br/>    A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for inline policy permissions | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_json_policy_documents"></a> [json\_policy\_documents](#input\_json\_policy\_documents) | INCOMPATIBLE with 'inline\_policy'. Use one or the other<br/>    List of rendered JSON from [aws\_iam\_policy\_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) data sources | `list(string)` | `[]` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours | `number` | `"3600"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use on IAM role created. If omitted, Terraform will assign a random, unique name | `string` | `null` | no |
| <a name="input_oidc_account_id"></a> [oidc\_account\_id](#input\_oidc\_account\_id) | An overriding AWS account ID where the OIDC provider lives; leave empty to use the current account ID for the AWS provider | `string` | `null` | no |
| <a name="input_oidc_audiences"></a> [oidc\_audiences](#input\_oidc\_audiences) | The audience to be added to the role policy. Set to sts.amazonaws.com for cross-account assumable role. Leave empty otherwise. | `list(string)` | `[]` | no |
| <a name="input_oidc_provider_urls"></a> [oidc\_provider\_urls](#input\_oidc\_provider\_urls) | List of URLs of the OIDC Providers | `list(string)` | `[]` | no |
| <a name="input_oidc_subjects"></a> [oidc\_subjects](#input\_oidc\_subjects) | The fully qualified OIDC subjects to be added to the role policy | `list(string)` | `[]` | no |
| <a name="input_oidc_wildcard_subjects"></a> [oidc\_wildcard\_subjects](#input\_oidc\_wildcard\_subjects) | The OIDC subject using wildcards to be added to the role policy | `list(string)` | `[]` | no |
| <a name="input_path"></a> [path](#input\_path) | Path of IAM role | `string` | `null` | no |
| <a name="input_saml_endpoints"></a> [saml\_endpoints](#input\_saml\_endpoints) | List of AWS SAML endpoints | `list(string)` | <pre>[<br/>  "https://signin.aws.amazon.com/saml"<br/>]</pre> | no |
| <a name="input_saml_provider_ids"></a> [saml\_provider\_ids](#input\_saml\_provider\_ids) | List of SAML provider IDs | `list(string)` | `[]` | no |
| <a name="input_saml_trust_actions"></a> [saml\_trust\_actions](#input\_saml\_trust\_actions) | Additional assume role trust actions for the SAML federated statement | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_trust_policy_conditions"></a> [trust\_policy\_conditions](#input\_trust\_policy\_conditions) | [Condition constraints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#condition) applied to the trust policy(s) enabled | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_trust_policy_permissions"></a> [trust\_policy\_permissions](#input\_trust\_policy\_permissions) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom trust policy permissions | <pre>map(object({<br/>    sid           = optional(string)<br/>    actions       = optional(list(string))<br/>    not_actions   = optional(list(string))<br/>    effect        = optional(string, "Allow")<br/>    resources     = optional(list(string))<br/>    not_resources = optional(list(string))<br/>    principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    not_principals = optional(list(object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })))<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })))<br/>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_name"></a> [name](#output\_name) | The name of the IAM role |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Stable and unique string identifying the IAM role |
<!-- END_TF_DOCS -->

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/LICENSE).
