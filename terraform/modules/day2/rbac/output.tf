output "storage_blob_reader_role_assignment_id" {
  value = azurerm_role_assignment.storage-contributor.id
}

output "keyvault_secret_user_role_assignment_idname" {
  value = azurerm_role_assignment.key-vault-secret-user.id
}