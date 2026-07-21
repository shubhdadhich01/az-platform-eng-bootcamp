#########################################################
# Storage account Private DNS
#########################################################

resource "azurerm_private_dns_zone" "sa-private-dns" {
  name                = var.storage_dns_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# Key Vault Private DNS
#########################################################

resource "azurerm_private_dns_zone" "kv-private-dns" {
  name                = var.key_vault_dns_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#########################################################
# Storage account hub vnet link
#########################################################

resource "azurerm_private_dns_zone_virtual_network_link" "hub-storage-link" {
  name                  = var.hub_storage_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sa-private-dns.name
  virtual_network_id    = var.hub_vnet_id
}

#########################################################
# Storage account spoke vnet link
#########################################################

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-storage-link" {
  name                  = var.spoke_storage_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sa-private-dns.name
  virtual_network_id    = var.spoke_vnet_id
}

#########################################################
# key vault hub vnet link
#########################################################

resource "azurerm_private_dns_zone_virtual_network_link" "hub-kv-link" {
  name                  = var.hub_kv_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv-private-dns.name
  virtual_network_id    = var.hub_vnet_id
}

#########################################################
# key vault spoke vnet link
#########################################################

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-kv-link" {
  name                  = var.spoke_kv_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv-private-dns.name
  virtual_network_id    = var.spoke_vnet_id
}
