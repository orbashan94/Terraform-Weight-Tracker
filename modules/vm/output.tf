output "nic_ids" {
  value = azurerm_network_interface.nic
}

output "nic_ids_ip_config" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}
