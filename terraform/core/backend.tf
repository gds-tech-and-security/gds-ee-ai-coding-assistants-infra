terraform {
  backend "s3" {
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true

    key = "core/terraform.tfstate"
  }
}
