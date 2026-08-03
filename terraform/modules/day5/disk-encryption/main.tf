#########################################################
# Disk Encryption Set
#########################################################

resource "azurerm_disk_encryption_set" "des" {
  name                      = var.des_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  key_vault_key_id          = var.key_vault_key_id
  auto_key_rotation_enabled = true
  identity {
    type         = "UserAssigned"
    identity_ids = [var.des_identity_id]
  }

  tags = var.tags
}

#########################################################
# Encrypted Managed Disk
#########################################################

resource "azurerm_managed_disk" "encrypt-disk" {
  name                   = var.disk_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = "Standard_LRS"
  create_option          = "Empty"
  disk_size_gb           = 2
  disk_encryption_set_id = azurerm_disk_encryption_set.des.id
  tags = var.tags
}

#########################################################
# Attach Disk
#########################################################

resource "azurerm_virtual_machine_data_disk_attachment" "disk-attachment" {
  managed_disk_id    = azurerm_managed_disk.encrypt-disk.id
  virtual_machine_id = var.vm_id
  lun                = 0
  caching            = "ReadWrite"
}

