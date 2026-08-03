
resource "time_sleep" "wait_for_rbac" {
  create_duration = "90s"
}

#########################################################
# Disk Encryption Set Identity
#########################################################

resource "azurerm_user_assigned_identity" "des-identity" {
  name                = var.des_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# Disk Encryption Set -> Key Vault
#########################################################

resource "azurerm_role_assignment" "des-crypto-user" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.des-identity.principal_id
}

#########################################################
# Storage  Managed Identity
#########################################################

resource "azurerm_user_assigned_identity" "storage_identity" {

  name                = "${var.storage_account_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# Storage Account -> Key Vault
#########################################################

resource "azurerm_role_assignment" "storage-crypto-user" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage_identity.principal_id
}

