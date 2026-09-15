output "role_arns" {
  description = "ARNs of each created roles"
  value = {
    for k, v in aws_iam_role.this :
    k => v.arn
  }
}
