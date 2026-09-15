output "name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this.name, null)
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this.arn, null)
}

output "unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this.unique_id, null)
}
