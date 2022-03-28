# Create Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                             = "vm_${var.vm_type}_${var.index}"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  vm_size                          = var.vm_size
  network_interface_ids            = [element(azurerm_network_interface.nic.*.id, var.index)]
  availability_set_id              = var.vm_type == "app" ? var.avset_id : ""
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "osdisk${var.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.vm_type == "app" ? "web-server-${var.index}" : "db-server"
    admin_username = var.vm_type == "app" ? var.admin_username : "${var.admin_username}-db"
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#Create network interfaces which are associated with the db virtual machines.
resource "azurerm_network_interface" "nic" {

  name                = "nic_${var.vm_type}_${var.index}"
  location            = var.location
  resource_group_name = var.resource_group_name


  ip_configuration {
    name                          = var.vm_type == "app" ? "ip_configuration" : "ip_configuration_db"
    subnet_id                     = var.snet_id
    private_ip_address_allocation = "Dynamic"
  }
}
