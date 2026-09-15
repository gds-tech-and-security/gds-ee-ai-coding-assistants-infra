#!/bin/bash
set -e

aws s3api create-bucket \
              --region "eu-west-2" \
              --bucket "gds-ee-ai-coding-assistants-infra-production-tfstate" \
              --create-bucket-configuration LocationConstraint="eu-west-2"

aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "22ff89586561fc2d52f77491e9f1eff1b80be33e" "9514f4ed3c841c96c43def0f0acbf177405ded12" # Same as Sandbox

aws iam create-role \
    --role-name DeployPipeline-GithubActions-production-plan \
    --assume-role-policy-document file://./assume-role.json

aws iam put-role-policy \
    --role-name DeployPipeline-GithubActions-production-plan \
    --policy-name DeployPipeline-GithubActions-production-plan \
    --policy-document file://./permissions-policy.json

aws iam create-role \
    --role-name DeployPipeline-GithubActions-production-apply \
    --assume-role-policy-document file://./assume-role.json

aws iam put-role-policy \
    --role-name DeployPipeline-GithubActions-production-apply \
    --policy-name DeployPipeline-GithubActions-production-apply \
    --policy-document file://./permissions-policy.json
