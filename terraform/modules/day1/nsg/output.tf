output "web_nsg" {
  value = {
    id = azurerm_network_security_group.web-nsg.id
    name = azurerm_network_security_group.web-nsg.name
  }
}

output "app_nsg" {
  value = {
    id = azurerm_network_security_group.app-nsg.id
    name = azurerm_network_security_group.app-nsg.name
  }
}