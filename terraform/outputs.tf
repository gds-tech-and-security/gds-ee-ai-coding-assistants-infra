output "bedrock_developer_policy_arn" {
  description = "ARN of the IAM policy for Bedrock developer access"
  value       = aws_iam_policy.bedrock_developer.arn
}