data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage-contributor" {
  scope                = var.storage_container_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.app_vm_principal_id
}

resource "azurerm_role_assignment" "key-vault-secret-user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_vm_principal_id
}

resource "azurerm_role_assignment" "kv-admin-rbac" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}