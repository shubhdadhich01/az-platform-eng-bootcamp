output "storage_diagnostics_id" {
  value = azurerm_monitor_diagnostic_setting.storage-setting.id
}

output "key_vault_diagnostics_id" {
  value = azurerm_monitor_diagnostic_setting.kv-setting.id
}