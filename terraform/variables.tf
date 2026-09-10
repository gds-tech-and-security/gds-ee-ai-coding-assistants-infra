variable "aws_region" {
  description = "AWS region used for the Bedrock experiment"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "gds-ee-ai-coding-assistants"
}