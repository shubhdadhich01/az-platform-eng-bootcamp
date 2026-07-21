resource "azurerm_monitor_diagnostic_setting" "storage-setting" {
  name                       = var.storage_diagnostics_name
  target_resource_id         = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_id
  enabled_metric {category = "Capacity"}
  enabled_metric {category = "Transaction"}
}

resource "azurerm_monitor_diagnostic_setting" "kv-setting" {
  name                       = var.key_vault_diagnostics_name
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_id
  enabled_log {category = "AuditEvent"}
  enabled_metric {category = "AllMetrics"}
}