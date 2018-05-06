output "subnet_id" {
    value = "${azurerm_subnet.asn.id}"
}

output "network_id" {
    value = "${azurerm_virtual_network.avn.id}"
}

output "resource_group" {
    value = "${}
}
