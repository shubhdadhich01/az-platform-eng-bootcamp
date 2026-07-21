#########################################################
# Private Endpoint for Storage account
#########################################################

resource "azurerm_private_endpoint" "storage_pe" {
  name                = var.sa_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "storage-account-connection"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-axxount-zone-group"
    private_dns_zone_ids = [var.sa_private_dns_zone_id]
  }
}

#########################################################
# Private Endpoint for Key Vault
#########################################################

resource "azurerm_private_endpoint" "key_vault_pe" {
  name                = var.key_vault_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "key-vault-connection"
    private_connection_resource_id = var.key_vault_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "key-vault-zone-group"
    private_dns_zone_ids = [var.kv_private_dns_zone_id]
  }
}