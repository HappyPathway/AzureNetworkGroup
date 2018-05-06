resource "azurerm_virtual_network" "avn" {
  name                = "${var.service_name}-net-${var.env}"
  address_space       = ["${var.network_cidr}"]
  location            = "${azurerm_resource_group.arg.location}"
  resource_group_name = "${azurerm_resource_group.arg.name}"
}

resource "azurerm_subnet" "asn" {
  name                 = "${var.service_name}-subnet-${var.env}"
  resource_group_name  = "${azurerm_resource_group.arg.name}"
  virtual_network_name = "${azurerm_virtual_network.avn.name}"
  address_prefix       = "${var.subnet_cidr}"
}

