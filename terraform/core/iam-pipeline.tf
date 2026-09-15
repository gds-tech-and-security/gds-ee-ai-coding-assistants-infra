module "iam_openid_connect_provider" {
  source = "../modules/iam-openid-connect-provider"

  enable_github_actions = true
}

data "aws_iam_policy_document" "access_management" {
  #checkov:skip=CKV_AWS_109,CKV_AWS_356:Pipeline role policy needs to manage IAM on all resources
  #checkov:skip=CKV2_AWS_40,CKV_AWS_107,CKV_AWS_110:Pipeline role policy needs to manage all IAM actions
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

data "aws_iam_policy_document" "state_bucket_management" {
  #checkov:skip=CKV_AWS_109,CKV_AWS_111,CKV_AWS_356:Pipeline role policy needs to manage all resources
  statement {
    sid    = "AllowManageStateBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketLogging",
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketVersioning",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:PutBucketEncryption",
      "s3:PutBucketLogging",
      "s3:PutBucketObjectLockConfiguration",
      "s3:PutBucketOwnershipControls",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "pipeline_s3_tfstate" {
  statement {
    sid    = "AllowAccessToS3Bucket"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}",
    ]
  }

  statement {
    sid    = "AllowModifyAnyObjectInStateKeyDir"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/*",
    ]
  }

  statement {
    sid    = "AllowDeleteTFLockFile"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/*.tflock",
    ]
  }
}

module "iam_role_pipeline_github_actions" {
  for_each = var.deployment_pipeline_oidc_subjects
  source   = "../modules/iam-role"

  name        = "DeployPipeline-GithubActions-${var.environment}-${each.key}"
  description = "Deployment pipeline role used by github actions (old role)"

  enable_github_oidc     = true
  oidc_wildcard_subjects = each.value

  json_policy_documents = [
    data.aws_iam_policy_document.pipeline_s3_tfstate.json,
    data.aws_iam_policy_document.access_management.json,
    data.aws_iam_policy_document.state_bucket_management.json
  ]
}

output "iam_role_pipeline_github_actions_arns" {
  value = {
    for k, v in module.iam_role_pipeline_github_actions :
    k => v.arn
  }
}
