# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]
}

# Create Public subnet
resource "azurerm_subnet" "app_subnet" {
  name                 = var.subnet_name_public
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_address_prefix]
  depends_on           = [azurerm_virtual_network.vnet]

}

# Create Private subnet
resource "azurerm_subnet" "db_subnet" {
  name                 = var.subnet_name_private
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_address_prefix]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }

  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

#Create public IP
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

#C reate Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                                       = "AllowInboundAppToDB"
    priority                                   = 100
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_ranges                    = ["5432", "22"]
    source_application_security_group_ids      = [azurerm_application_security_group.asg_public.id]
    destination_application_security_group_ids = [azurerm_application_security_group.asg_private.id]
  }

  security_rule {
    name                                       = "AllowAllInbound"
    priority                                   = 110
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "8080"
    source_address_prefix                      = "*"
    destination_application_security_group_ids = [azurerm_application_security_group.asg_public.id]
  }

  security_rule {
    name                                       = "AllowSSH_VMtoVM"
    priority                                   = 120
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "*"
    source_port_range                          = "*"
    destination_port_ranges                    = ["8080", "22"]
    source_address_prefixes                    = module.vm_app.*.nic_ids_ip_config
    destination_application_security_group_ids = [azurerm_application_security_group.asg_public.id, azurerm_application_security_group.asg_private.id]
  }

  security_rule {
    name                                       = "AllowSSHToAdmin"
    priority                                   = 130
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "*"
    source_port_range                          = "*"
    destination_port_ranges                    = ["8080", "22"]
    source_address_prefix                      = var.admin_ip_address
    destination_application_security_group_ids = [azurerm_application_security_group.asg_public.id, azurerm_application_security_group.asg_private.id]
  }

  security_rule {
    name                                       = "DenySSHToAll"
    priority                                   = 140
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "22"
    source_address_prefix                      = "*"
    destination_application_security_group_ids = [azurerm_application_security_group.asg_public.id]
  }

  security_rule {
    name                                       = "DenyAllInbound"
    priority                                   = 150
    direction                                  = "Inbound"
    access                                     = "Deny"
    protocol                                   = "*"
    source_port_range                          = "*"
    destination_port_range                     = "*"
    source_address_prefix                      = "*"
    destination_application_security_group_ids = [azurerm_application_security_group.asg_private.id]
  }

}

# Create app application security group 
resource "azurerm_application_security_group" "asg_public" {
  name                = "public_asg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# Create db application security group
resource "azurerm_application_security_group" "asg_private" {
  name                = "private_asg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# association application security group with app
resource "azurerm_network_interface_application_security_group_association" "asg_association_app" {
  count                         = var.app_instances
  network_interface_id          = module.vm_app.*.nic_ids[count.index].id
  application_security_group_id = azurerm_application_security_group.asg_public.id
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# # This block creates the application security group association for the db server
# resource "azurerm_network_interface_application_security_group_association" "asg_association_db" {
#   count                         = var.db_instances
#   network_interface_id          = module.vm_db.*.nic_ids[count.index].id
#   application_security_group_id = azurerm_application_security_group.asg_private.id
#   depends_on = [
#     azurerm_resource_group.rg
#   ]
# }



# Create Load Balancer
resource "azurerm_lb" "public_lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = var.public_ip_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

# Load Balancer rules
resource "azurerm_lb_rule" "lb_rule_SSH" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_public_ip.public_ip.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_address_pool.id]
}

resource "azurerm_lb_rule" "lb_rule_HTTP" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_public_ip.public_ip.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_address_pool.id]
}

# Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  name            = var.lb_backend_address_pool_name
  loadbalancer_id = azurerm_lb.public_lb.id
}


#Associate app NIC with nsg
resource "azurerm_network_interface_security_group_association" "nic_association_nsg" {
  count                     = var.nic_app_association_instances
  network_interface_id      = module.vm_app.*.nic_ids[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ###########/ Associate NIC (db) with NSG /#########################################
# resource "azurerm_network_interface_security_group_association" "nic_association_db_nsg" {
#   count                     = var.nic_db_association_instances
#   network_interface_id      = module.vm_db.*.nic_ids[count.index].id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# Associate NIC with backend pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_pool_association" {
  count                   = var.nic_app_association_instances
  ip_configuration_name   = "ip_configuration"
  network_interface_id    = module.vm_app.*.nic_ids[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool.id
}

#Create Availability set
resource "azurerm_availability_set" "avset" {
  name                         = var.avset_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = var.app_instances
  platform_update_domain_count = var.app_instances
  managed                      = true
  depends_on = [
    azurerm_resource_group.rg
  ]
}



# Create app VMs
module "vm_app" {
  source = "./modules/vm"

  count               = var.app_instances
  index               = count.index
  vm_type             = "app"
  vm_name             = "${var.vm_name}_${count.index}"
  vm_size             = var.vm_size
  location            = var.location
  snet_id             = azurerm_subnet.app_subnet.id
  avset_id            = azurerm_availability_set.avset.id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}


#Create Storage account
resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}
