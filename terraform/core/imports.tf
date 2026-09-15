data "aws_caller_identity" "current" {}

import {
  id = "gds-ee-ai-coding-assistants-infra-${var.environment}-tfstate"
  to = module.s3_state.aws_s3_bucket.this
}

import {
  id = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  to = module.iam_openid_connect_provider.aws_iam_openid_connect_provider.github[0]
}

import {
  id = "DeployPipeline-GithubActions-${var.environment}-plan"
  to = module.iam_role_pipeline_github_actions["plan"].aws_iam_role.this
}

import {
  id = "DeployPipeline-GithubActions-${var.environment}-apply"
  to = module.iam_role_pipeline_github_actions["apply"].aws_iam_role.this
}

import {
  id = "DeployPipeline-GithubActions-${var.environment}-plan:DeployPipeline-GithubActions-${var.environment}-plan"
  to = module.iam_role_pipeline_github_actions["plan"].aws_iam_role_policy.document[0]
}

import {
  id = "DeployPipeline-GithubActions-${var.environment}-apply:DeployPipeline-GithubActions-${var.environment}-apply"
  to = module.iam_role_pipeline_github_actions["apply"].aws_iam_role_policy.document[0]
}