#########################################################
# Least-Privilege Role Assignments (scoped to one each)
#########################################################

resource "time_sleep" "wait_for_rbac" {
  create_duration = "90s"
}

resource "azurerm_role_assignment" "func_blob_reader" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.data_container_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_function_app.manifest_processor.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_kv_secret_user" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.manifest_processor.identity[0].principal_id
}

resource "azurerm_role_assignment" "ansible_blob_contributor" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.storage_container_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.ansible_vm_principle_id
}

resource "azurerm_role_assignment" "ansible_monitoring_reader" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = azurerm_application_insights.func_ai.id
  role_definition_name = "Monitoring Reader"
  principal_id         = var.ansible_vm_principle_id
}