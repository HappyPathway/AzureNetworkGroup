resource "azurerm_network_security_group" "sg" {
    name                = "${var.service_name}-sg"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.arg.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        service = "${var.service_name}"
        environment = "${var.env}"
    }
}