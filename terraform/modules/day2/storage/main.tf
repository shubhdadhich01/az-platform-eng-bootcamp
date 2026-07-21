#########################################################
# Storage Account
#########################################################

resource "azurerm_storage_account" "sotarage-account" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {days = 7}
  }
}

#########################################################
# Storage Account Containeer
#########################################################

resource "azurerm_storage_container" "appdata" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sotarage-account.id
  container_access_type = "private"
}