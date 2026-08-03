#########################################################
# Storage Customer Managed Key
#########################################################

resource "azurerm_storage_account_customer_managed_key" "cmk-sa" {
  storage_account_id        = var.storage_account_id
  key_vault_key_id          = var.key_vault_key_id
  user_assigned_identity_id = var.user_assigned_identity_id
}