#!/bin/bash
wget https://releases.hashicorp.com/terraform/0.8.5/terraform_0.8.5_linux_amd64.zip
unzip ./terraform_0.8.5_linux_amd64.zip
export PATH=$PATH\:./
rm ./terraform_0.8.5_linux_amd64.zip

terraform apply -var 'dns_zone_name=example.com' -var 'storage_account_name=uniquesaname123'
./push_state_to_azure.sh uniquesaname123
terraform destroy -var 'dns_zone_name=example.com' -var 'storage_account_name=uniquesaname123' -force
