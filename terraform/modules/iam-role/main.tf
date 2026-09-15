data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = try(data.aws_caller_identity.current.account_id, "")
  partition  = try(data.aws_partition.current.partition, "")

  root_identifier = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"

  oidc_providers = [for url in var.oidc_provider_urls : replace(url, "https://", "")]
}

###########
# IAM Role
###########

data "aws_iam_policy_document" "this" {
  # Generic OIDC
  dynamic "statement" {
    for_each = var.enable_oidc ? local.oidc_providers : []

    content {
      effect = "Allow"
      actions = [
        "sts:AssumeRoleWithWebIdentity",
        "sts:TagSession"
      ]

      principals {
        type = "Federated"

        identifiers = ["arn:${local.partition}:iam::${coalesce(var.oidc_account_id, local.account_id)}:oidc-provider/${statement.value}"]
      }

      dynamic "condition" {
        for_each = length(var.oidc_subjects) > 0 ? local.oidc_providers : []

        content {
          test     = "StringEquals"
          variable = "${statement.value}:sub"
          values   = var.oidc_subjects
        }
      }

      dynamic "condition" {
        for_each = length(var.oidc_wildcard_subjects) > 0 ? local.oidc_providers : []

        content {
          test     = "StringLike"
          variable = "${statement.value}:sub"
          values   = var.oidc_wildcard_subjects
        }
      }

      dynamic "condition" {
        for_each = length(var.oidc_audiences) > 0 ? local.oidc_providers : []

        content {
          test     = "StringEquals"
          variable = "${statement.value}:aud"
          values   = var.oidc_audiences
        }
      }

      # Generic conditions
      dynamic "condition" {
        for_each = var.trust_policy_conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  # GitHub OIDC
  dynamic "statement" {
    for_each = var.enable_github_oidc ? [1] : []

    content {
      sid = "GithubOidcAuth"
      actions = [
        "sts:AssumeRoleWithWebIdentity",
        "sts:TagSession"
      ]

      principals {
        type        = "Federated"
        identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${var.github_provider}"]
      }

      condition {
        test     = "ForAllValues:StringEquals"
        variable = "${var.github_provider}:iss"
        values   = ["https://${var.github_provider}"]
      }

      condition {
        test     = "ForAllValues:StringEquals"
        variable = "${var.github_provider}:aud"
        values   = coalescelist(var.oidc_audiences, ["sts.amazonaws.com"])
      }

      dynamic "condition" {
        for_each = length(var.oidc_subjects) > 0 ? [1] : []

        content {
          test     = "StringEquals"
          variable = "${var.github_provider}:sub"
          # Strip `repo:` to normalize for cases where users may prepend it
          values = [for subject in var.oidc_subjects : "repo:${trimprefix(subject, "repo:")}"]
        }
      }

      dynamic "condition" {
        for_each = length(var.oidc_wildcard_subjects) > 0 ? [1] : []

        content {
          test     = "StringLike"
          variable = "${var.github_provider}:sub"
          # Strip `repo:` to normalize for cases where users may prepend it
          values = [for subject in var.oidc_wildcard_subjects : "repo:${trimprefix(subject, "repo:")}"]
        }
      }

      # Generic conditions
      dynamic "condition" {
        for_each = var.trust_policy_conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  # SAML
  dynamic "statement" {
    for_each = var.enable_saml ? [1] : []

    content {
      effect = "Allow"
      actions = compact(distinct(concat(
        [
          "sts:TagSession",
          "sts:AssumeRoleWithSAML",
        ],
      var.saml_trust_actions)))

      principals {
        type        = "Federated"
        identifiers = var.saml_provider_ids
      }

      condition {
        test     = "StringEquals"
        variable = "SAML:aud"
        values   = var.saml_endpoints
      }

      # Generic conditions
      dynamic "condition" {
        for_each = var.trust_policy_conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  # Generic statements
  dynamic "statement" {
    for_each = var.trust_policy_permissions != null ? var.trust_policy_permissions : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type = principals.value.type
          identifiers = concat(
            [local.root_identifier],
            principals.value.identifiers
          )
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name        = var.name
  path        = var.path
  description = var.description

  assume_role_policy    = data.aws_iam_policy_document.this.json
  max_session_duration  = var.max_session_duration
  force_detach_policies = true

  tags = var.tags
}

###############################
# IAM Role attachment policies
###############################

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.attach_policies

  policy_arn = each.value
  role       = aws_iam_role.this.name
}

#################################
# IAM Role JSON policy documents
#################################

data "aws_iam_policy_document" "document_combined" {
  count = length(var.json_policy_documents) > 0 ? 1 : 0

  source_policy_documents = var.json_policy_documents
}

resource "aws_iam_role_policy" "document" {
  count = length(var.json_policy_documents) > 0 ? 1 : 0

  role   = aws_iam_role.this.name
  name   = var.name
  policy = data.aws_iam_policy_document.document_combined[0].json
}

#########################
# IAM Role Inline policy
#########################

data "aws_iam_policy_document" "inline" {
  count = var.inline_policy != null ? 1 : 0

  dynamic "statement" {
    for_each = var.inline_policy != null ? var.inline_policy : {}

    content {
      sid           = try(coalesce(statement.value.sid, statement.key))
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? statement.value.condition : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy != null ? 1 : 0

  role   = aws_iam_role.this.name
  name   = var.name
  policy = data.aws_iam_policy_document.inline[0].json
}
