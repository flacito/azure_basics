# azure_basics

[![Build Status](https://travis-ci.org/flacito/azure_basics.svg?branch=master)](https://travis-ci.org/flacito/azure_basics)

Creates some basics in Azure that you can use to create a Continuous Delivery (CD) pipeline. Currently it just:

1. Creates a DNS zone for a given domain (add/remove A records to the zone as part of your CD pipeline)
2. Creates a storage account for things that will come and go. We've found that sometimes it can take upwards of 20-30 minutes to create a storage account in azure, so having this account cuts that wait out.

This can be done against any azure account. It sets up the basics to be able to deploy a more application-centric Terraform configuration. This includes setting up a DNS zone for configuring DNS A records, etc. for your VMs and LBs. It also includes setting up a storage account which you can use to make creating storage much faster (storage accounts take a while to create).

1. Make sure you have all your Azure ARM_* env vars set for your subscription
2. run `terraform apply -var 'storage_account_name=uniqueazurestorageaccountname'` -var 'dns_zone_name=yourdowmain.com'` to create the basics
3. run `./push_state_to_azure.sh <uniquesaname123>` to push the state to the Azure backend
4. use the remote in another Terraform configuration to import and use the state (see below)

When you apply the main Terraform configuration in this repo via `terraform apply` you should get these outputs:

```
dns_zone_name = yourdowmain.com
primary_blob_endpoint = https://uniquesaname123.blob.core.windows.net/
resource_group_name = basics
storage_account_name = uniquesaname123
```

Then using the provided shell script, you push the basics Terraform configuration state to Azure as a backend using the basic storage account you just created:

```
> ./push_state_to_azure.sh uniquesaname123
Pushing Terraform state to Azure.
Remote state management enabled
Remote state configured and pulled.
```

Here's how you would use the remote state in an application-centric Terraform configuration elsewhere after you run the main plan for your basics and push it to the Azure backend. First you have to pull it in using a data resource:

```
data "terraform_remote_state" "basics" {
  backend = "azure"
  config {
    resource_group_name  = "${var.basics_resource_group}"
    storage_account_name = "${var.basics_storage_account_name}"
    container_name       = "terraform-state"
    key                  = "${var.basics_state_file_name}"
  }
}
```

Then later in your Terraform application-centric configuration, you can use the outputs. Here's an example of creating a storage container in the basic storage account initially created by the basic Terraform configuration:

```
resource "azurerm_storage_container" "example" {
    name = "example-storage-container-${var.names_suffix}"
    resource_group_name = "${data.terraform_remote_state.basics.resource_group_name}"
    storage_account_name = "${data.terraform_remote_state.basics.storage_account_name}"
    container_access_type = "private"
}
```
