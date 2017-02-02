#!/bin/bash

if [ -z "$1" ]; then
  printf "Please provide the Azure storage account name.\n"
  printf "Usage: push_state_to_azure.sh <Azure storage account name>"
else
  printf "Pushing Terraform state to Azure.\n"
  terraform remote config \
    -backend=azure \
    -backend-config="resource_group_name=basics" \
    -backend-config="storage_account_name=$1" \
    -backend-config="container_name=terraform-state" \
    -backend-config="key=bcbbasics.terraform.tfstate"
fi
