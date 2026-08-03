#==============================================================================
# Customer Managed Key (CMK) + Rotation Policy
#==============================================================================

resource "azurerm_key_vault_key" "cmk-key" {
  name         = var.cmk_name
  key_vault_id = var.key_vault_id

  key_type = "RSA"
  key_size = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P90D"
    notify_before_expiry = "P30D"
  }
  tags = var.tags
}