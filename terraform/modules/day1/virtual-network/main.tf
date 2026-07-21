##############################################
# Resource Group
##############################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

###############################
# Hub Network
###############################

resource "azurerm_virtual_network" "hub-vnet" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "hub-subnet" {
  for_each             = var.hub_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = each.value.address_prefixes
}

##############################################
# Spoke Virtual Network
##############################################

resource "azurerm_virtual_network" "spoke-vnet" {
  name                = var.spoke_vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.spoke_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "spoke-subnet" {
  for_each             = var.spoke_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
  address_prefixes     = each.value.address_prefixes
}

##############################################
# Hub -> Spoke Peering
##############################################

resource "azurerm_virtual_network_peering" "hub_to_spoke_peering" {
  name = format("%s-to-%s",
                 azurerm_virtual_network.hub-vnet.name,
                 azurerm_virtual_network.spoke-vnet.name)
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

##############################################
# Spoke -> Hub Peering
##############################################

resource "azurerm_virtual_network_peering" "spoke-to-hub-peering" {
  name = format("%s-to-%s",
                 azurerm_virtual_network.spoke-vnet.name, 
                 azurerm_virtual_network.hub-vnet.name)
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
