output "des_role_assignment_id" {
  value = azurerm_role_assignment.des-crypto-user.id
}

output "storage_role_assignment_id" {
  value = azurerm_role_assignment.storage-crypto-user.id
}

output "des_identity_id" {
 value = azurerm_user_assigned_identity.des-identity.id 
}

output "storage_identity_id" {
  value = azurerm_user_assigned_identity.storage_identity.id
}