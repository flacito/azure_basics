#!/bin/sh
# Downloads Terraform to the temp directory, if needed.
# Set environment variable TERRAFORM_VERSION to override default version.
# All arguments as passed to terraform as-is.
#
# Using this primarily for Travis CI builds

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
  identify_platform

  # Setup terraform version
  TF_VERSION=${TERRAFORM_VERSION='0.8.5'}

  # Setup temp directory
  if [[ "$platform" == 'windows' ]]; then
    TEMP_DIRECTORY="${TEMP}"
  else
    TEMP_DIRECTORY="${TMPDIR}"
  fi

  # Setup paths
  TF_ZIP="${TEMP_DIRECTORY}/terraform_${TF_VERSION}.zip"
  TF_PATH="${TEMP_DIRECTORY}/terraform_${TF_VERSION}/"
  PATH=$TF_PATH:$PATH

  setup_vsts_build_vars
}

function setup_vsts_build_vars {
  # Name suffix from build id.
  if [[ -z "${BUILD_BUILDNUMBER}" ]]; then
    # -nz didn't work on the bash for Windows (git) in Azure.
    echo "" > /dev/null
  else
    export TF_VAR_names_suffix=`echo "${BUILD_BUILDNUMBER}" | awk '{print tolower($0)}'`
  fi
}

# Downloads the terraform zip
function download {
  if [[ "$platform" == 'linux' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
  elif [[ "$platform" == 'macos' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_darwin_amd64.zip"
  elif [[ "$platform" == 'windows' ]]; then
    url="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_windows_amd64.zip"
  fi
  curl -o ${TF_ZIP} ${url}
  unzip ${TF_ZIP} -d ${TF_PATH}
}

# Checks if terraform is downloaded and the same version
function tf_exists {
  terraform --version | grep -q ${TF_VERSION}
}

function generate_ssh_keys {
  if [ ! -d ~/.ssh/ ]; then
    mkdir -p ~/.ssh/
  fi
  if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "Generating SSH keys at ~/.ssh/id_rsa"
    ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
  fi
}

# Downloads if the check does not pass.
function download_if_needed {
  if ! tf_exists; then
    download
  fi
}

setup
download_if_needed
generate_ssh_keys
terraform "$@"
