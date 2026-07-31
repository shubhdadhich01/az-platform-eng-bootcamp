output "log_workspace_id" {
  value = azurerm_log_analytics_workspace.log-analytics.id
}

output "log_workspace_name" {
  value = azurerm_log_analytics_workspace.log-analytics.name
}

output "workspace_customer_id" {
  value = azurerm_log_analytics_workspace.log-analytics.workspace_id
}

output "workspace_location" {
  value = azurerm_log_analytics_workspace.log-analytics.location
}