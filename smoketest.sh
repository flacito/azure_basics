#!/bin/bash
function identify_platform {
  uname=`uname`
  if [[ "$uname" == 'Linux' ]]; then
    platform="linux"
  elif [[ "$uname" == 'Darwin' ]]; then
    platform="macos"
  elif [[ "$uname" == MINGW64* ]]; then
    platform="windows"
  fi
}

function setup {
  SEED=$(( ( RANDOM % 1000 )  + 100 ))
  SEED="basicstest${SEED}"

  rm -Rf ${TF_PATH}
  rm -Rf .terraform
  rm -Rf *.tfstate*

  identify_platform

  # Setup terraform version
  TF_VERSION=${TERRAFORM_VERSION='0.8.5'}

  TEMP_DIRECTORY="./tmp"
  mkdir ${TEMP_DIRECTORY}

  # Setup paths
  TF_ZIP="${TEMP_DIRECTORY}/terraform_${TF_VERSION}.zip"
  TF_PATH="${TEMP_DIRECTORY}/terraform_${TF_VERSION}/"

  if [[ "$platform" == 'linux' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
  elif [[ "$platform" == 'macos' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_darwin_amd64.zip"
  elif [[ "$platform" == 'windows' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_windows_amd64.zip"
  fi

  curl -o ${TF_ZIP} ${url}
  unzip ${TF_ZIP} -d ${TF_PATH}

  PATH=${TF_PATH}:${PATH}
}

function smoke {
  printf "Running smoke test using ${SEED}.\n"

  terraform apply -var "resource_group_name=${SEED}" -var "dns_zone_name=example.com" -var "storage_account_name=${SEED}"
  terraform show
  ./push_state_to_azure.sh ${SEED} ${SEED}
  terraform destroy -force

  rm -Rf ${TF_PATH}
  rm -Rf .terraform
  rm -Rf *.tfstate*
}

setup
smoke
