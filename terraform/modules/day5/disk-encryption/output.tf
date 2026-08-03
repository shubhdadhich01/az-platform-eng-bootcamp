output "disk_encryption_set_id" {
  value = azurerm_disk_encryption_set.des.id
}

output "encrypted_disk_id" {
  value = azurerm_managed_disk.encrypt-disk.id
}

output "encrypted_disk_name" {
  value = azurerm_managed_disk.encrypt-disk.name
}