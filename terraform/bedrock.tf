data "aws_bedrock_foundation_models" "anthropic" {
  by_provider        = "Anthropic"
  by_output_modality = "TEXT"
}