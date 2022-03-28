resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "wt-db.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]

}

# Attach my virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet" {
  name                  = "dns_vnet"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on            = [azurerm_resource_group.rg]

}

# Create flexible server
resource "azurerm_postgresql_flexible_server" "psql_server" {
  name                   = "weighttracker-db"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.db_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns_zone.id
  administrator_login    = var.admin_db_username
  administrator_password = var.admin_db_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.dns_vnet]

}
