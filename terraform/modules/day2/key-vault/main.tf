# Get the Tenent ID

data "azurerm_client_config" "current" {}

#########################################################
# Key vault
#########################################################

resource "azurerm_key_vault" "key-vault"{
  name                          = "${var.key_vault_name}-t1"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = true
  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  tags = var.tags
}