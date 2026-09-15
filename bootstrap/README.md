# Account Bootstrap Script

A shell script to create the minimum resources for us to be able to run the pipeline for the account

## Why is this needed?

The script is needed to bootstrap production using a PAW.
Because PAWs are restricted, Terraform hasn't run in the past due to providers not being allowlisted.
Therefore, we'd need to manually create the state bucket and IAM roles for the pipeline to run.

## Usage

1. Run the [`bootstrap-access.sh`](https://github.com/alphagov/gds-aws-organisation-accounts/blob/main/bootstrap/bootstrap_access.sh) script from the `gds-aws-organisation-accounts` repository to setup AWS vault
2. Get an authenticated shell with `aws-vault exec bootstrap zsh`
3. Run the `bootstrap-account.sh` script from the bootstrap/ directory
4. Run the CI pipeline to import all the resources created into the tfstate.
