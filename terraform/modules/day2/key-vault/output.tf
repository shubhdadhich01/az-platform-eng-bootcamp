output "key_vault_id" {
  value = azurerm_key_vault.key-vault.id
}

output "key_vault_name" {
  value = azurerm_key_vault.key-vault.name
}

output "vault_uri" {
  value = azurerm_key_vault.key-vault.vault_uri
}