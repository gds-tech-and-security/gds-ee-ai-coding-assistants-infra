config {
  call_module_type = "all"
  force = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.47.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform-sort" {
  enabled = true
  version = "0.3.1"
  source  = "github.com/kenske/tflint-ruleset-terraform-sort"
}

rule "terraform_list_order" {
  enabled = true
}

rule "terraform_variables_order" {
  enabled = false
}
