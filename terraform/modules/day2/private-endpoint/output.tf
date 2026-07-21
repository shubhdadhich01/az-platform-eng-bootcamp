output "sa_private_endpoint_id" {
  value = azurerm_private_endpoint.storage_pe.id
}

output "key_vault_private_endpoint_id" {
  value = azurerm_private_endpoint.key_vault_pe.id
}

output "sa_private_endpoint_name" {
  value = azurerm_private_endpoint.storage_pe.name
}

output "key_vault_private_endpoint_name" {
  value = azurerm_private_endpoint.key_vault_pe.name
}