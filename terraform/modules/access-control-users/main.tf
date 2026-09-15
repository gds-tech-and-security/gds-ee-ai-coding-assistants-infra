locals {
  default_roles = {
    admin = {
      policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
      user_arns = flatten(
        [for u in lookup(var.users_roles, "admin", []) :
          formatlist(
            "arn:aws:iam::%s:user/%s",
            var.role_assuming_account_id,
            u,
      )])
    }

    read-only = {
      policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      user_arns = flatten(
        [for u in lookup(var.users_roles, "read-only", []) :
          formatlist(
            "arn:aws:iam::%s:user/%s",
            var.role_assuming_account_id,
            u,
      )])
    }
  }

  active_roles = {
    for k, v in local.default_roles :
    k => v
    if length(v.user_arns) > 0
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  for_each = local.active_roles

  name               = "${each.key}-access"
  assume_role_policy = data.aws_iam_policy_document.this_role_assume_role_policy[each.key].json
}

data "aws_iam_policy_document" "this_role_assume_role_policy" {
  for_each = local.active_roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = concat(
        ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
        each.value.user_arns
      )
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        "true"
      ]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.gds_cidrs_list
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.active_roles

  role       = aws_iam_role.this[each.key].name
  policy_arn = each.value.policy_arn
}
