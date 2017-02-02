variable "resource_group_name" {
  type = "string"
  default = "basics"
}

variable "dns_zone_name" {
  type = "string"
}

variable "storage_account_name" {
  type = "string"
}

resource "azurerm_resource_group" "basics" {
  name     = "${var.resource_group_name}"
  location = "East US"
}

resource "azurerm_dns_zone" "basics" {
   name = "${var.dns_zone_name}"
   resource_group_name = "${azurerm_resource_group.basics.name}"
}

resource "azurerm_storage_account" "basics" {
    name = "${var.storage_account_name}"
    resource_group_name = "${azurerm_resource_group.basics.name}"
    location = "East US"
    account_type = "Standard_LRS"
}

resource "azurerm_storage_container" "terraform" {
    name = "terraform-state"
    resource_group_name = "${azurerm_resource_group.basics.name}"
    storage_account_name = "${azurerm_storage_account.basics.name}"
    container_access_type = "private"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.basics.name}"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.basics.name}"
}

output "dns_zone_name" {
  value = "${azurerm_dns_zone.basics.name}"
}

output "primary_blob_endpoint" {
  value = "${azurerm_storage_account.basics.primary_blob_endpoint}"
}
