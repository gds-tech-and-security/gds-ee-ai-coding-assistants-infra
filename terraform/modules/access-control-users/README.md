# Description

Creates IAM roles for users to assume.

List of roles:

|Key|AWS Role Name|Policy|
|---|---|---|
|`admin`|`admin-access`|`arn:aws:iam::aws:policy/AdministratorAccess`|
|`read-only`|`read-only-access`|`arn:aws:iam::aws:policy/ReadOnlyAccess`|

## Usage

```hcl
module "access_control_users" {
  source      = "..."

  users_roles = {
    admin = [
      "admin1"
    ]
    read-only = [
      "user1"
    ]
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
| <a name="input_gds_cidrs_list"></a> [gds\_cidrs\_list](#input\_gds\_cidrs\_list) | ip ranges we allow to assume this role | `list(string)` | <pre>[<br/>  "159.254.101.107/32",<br/>  "159.254.101.75/32",<br/>  "164.137.3.121/32",<br/>  "164.137.3.89/32",<br/>  "217.196.229.77/32",<br/>  "217.196.229.79/32",<br/>  "217.196.229.80/32",<br/>  "217.196.229.81/32",<br/>  "51.149.8.0/25",<br/>  "51.149.8.128/29"<br/>]</pre> | no |
| <a name="input_role_assuming_account_id"></a> [role\_assuming\_account\_id](#input\_role\_assuming\_account\_id) | The account id in which resides the users we're allowing to assume this role | `string` | `"622626885786"` | no |
| <a name="input_users_roles"></a> [users\_roles](#input\_users\_roles) | Map of IAM users grouped by role. Each role is assigned a default policy, and contain a list of users who can assume the role.<br/>    Users must exist in the gds-users AWS account to be valid.<br/>      E.g. first.lastname@digital.cabinet-office.gov.uk | `map(list(string))` | <pre>{<br/>  "admin": [],<br/>  "read-only": []<br/>}</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_role_arns"></a> [role\_arns](#output\_role\_arns) | ARNs of each created roles |
<!-- END_TF_DOCS -->
