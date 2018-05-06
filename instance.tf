resource "azurerm_managed_disk" "amd" {
  name                 = "${var.service_name}-${var.env}-amd${format("%03d", count.index + 1)}"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.arg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.disk_size}"
  count                = "${var.count}"
}

resource "azurerm_virtual_machine" "avm" {
  name                  = "${var.service_name}-${var.env}-avm${format("%03d", count.index + 1)}"
  location              = "${azurerm_resource_group.arg.location}"
  resource_group_name  = "${azurerm_resource_group.arg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.ani.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"
  count                 = "${var.count}"
  depends_on = [
                "azurerm_public_ip.api",
                "azurerm_network_interface.ani",
                "azurerm_managed_disk.amd",
                "azurerm_network_security_group.sg"
                ]

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.service_name}-${var.env}-os${format("%03d", count.index + 1)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${var.service_name}-${var.env}-disk${format("%03d", count.index + 1)}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  storage_data_disk {
    name            = "${element(azurerm_managed_disk.amd.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.amd.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${var.disk_size}"
  }

  os_profile {
    computer_name  = "${var.service_name}-${var.env}-${format("%03d", count.index + 1)}"
    admin_username = "${var.system_user}"
    admin_password = "${var.system_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path     = "/home/${var.system_user}/.ssh/authorized_keys"
      key_data = "${file("./keys/terraform.pub")}"
    }
  }

  tags {
    service = "${var.service_name}"
    environment = "${var.env}"
  }
}

resource "azurerm_public_ip" "api" {
  name                         = "${var.service_name}-${var.env}-ip${format("%03d", count.index + 1)}"
  location                     = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.arg.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
  count = "${var.count}"
  tags {
    environment = "${var.env}"
    service = "${var.service_name}"
  }
}

resource "azurerm_network_interface" "ani" {
  name                = "${var.service_name}-${var.env}-ani${format("%03d", count.index + 1)}"
  location            = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.arg.name}"
  count = "${var.count}"
  ip_configuration {
    name                          = "${var.service_name}-ani${format("%03d", count.index + 1)}"
    subnet_id                     = "${azurerm_subnet.asn.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.api.*.id, count.index)}"
  }
}
