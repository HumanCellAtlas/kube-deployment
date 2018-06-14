#!/usr/bin/env bash
[[ -d .terraform ]] || terraform init \
  -backend-config="bucket=$TF_VAR_terraform_bucket" \
  -backend-config="profile=$TF_VAR_aws_profile" \
  -backend-config="region=$TF_VAR_aws_region" \
  -backend-config="key=$TF_VAR_terraform_key"
