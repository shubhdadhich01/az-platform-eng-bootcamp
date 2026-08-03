output "cmk_id" {
  value = azurerm_key_vault_key.cmk-key.id
}

output "cmk_name" {
  value = azurerm_key_vault_key.cmk-key.name
}

output "versionless_key_id" {
  value = azurerm_key_vault_key.cmk-key.versionless_id
}

output "key_version" {
  value = azurerm_key_vault_key.cmk-key.version
}