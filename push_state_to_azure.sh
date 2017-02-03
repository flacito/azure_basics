#!/bin/bash

if [ -z "$2" ]; then
  printf "Please provide the Azure storage account name.\n"
  printf "Usage: push_state_to_azure.sh <Azure resource group name> <Azure storage account name>"
else
  printf "Pushing Terraform state to Azure.\n"
  terraform remote config \
    -backend=azure \
    -backend-config="resource_group_name=$1" \
    -backend-config="storage_account_name=$2" \
    -backend-config="container_name=terraform-state" \
    -backend-config="key=bcbbasics.terraform.tfstate"

  terraform remote config -disable
fi
