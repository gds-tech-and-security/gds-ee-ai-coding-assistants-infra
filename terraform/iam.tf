data "aws_iam_policy_document" "bedrock_developer" {

  statement {
    sid    = "InvokeAnthropicModels"
    effect = "Allow"

    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]

    resources = [
      "arn:${data.aws_partition.current.partition}:bedrock:*::foundation-model/anthropic.*",

      # Allow account-owned inference profiles if we introduce them later.
      "arn:${data.aws_partition.current.partition}:bedrock:*:${data.aws_caller_identity.current.account_id}:inference-profile/*",
      "arn:${data.aws_partition.current.partition}:bedrock:*:${data.aws_caller_identity.current.account_id}:application-inference-profile/*"
    ]
  }

  statement {
    sid    = "ReadBedrockConfiguration"
    effect = "Allow"

    actions = [
      "bedrock:GetFoundationModel",
      "bedrock:ListFoundationModels",
      "bedrock:GetInferenceProfile",
      "bedrock:ListInferenceProfiles"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "UseBedrockApiKey"
    effect = "Allow"

    actions = [
      "bedrock:CallWithBearerToken"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock_developer" {
  name        = "${var.project_name}-developer"
  description = "Allows DevEx developers to use approved Amazon Bedrock models"
  policy      = data.aws_iam_policy_document.bedrock_developer.json
}