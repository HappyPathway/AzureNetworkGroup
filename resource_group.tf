resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}