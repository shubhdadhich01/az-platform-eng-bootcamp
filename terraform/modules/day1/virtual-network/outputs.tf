output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
    value = azurerm_resource_group.rg.location
}

#######################################
# Hub
#######################################

output "hub_vnet_id" {
   value = azurerm_virtual_network.hub-vnet.id
}

output "hub_vnet_name" {
    value = azurerm_virtual_network.hub-vnet.name
}

output "hub_subnet" {
    value = {
        for subnet_name, subnet in azurerm_subnet.hub-subnet: # this will iterate through each subnet.
        subnet_name => subnet.id # this will be consider as key value pair where name is key and id is it pair.
    }
}

#######################################
# Spoke
#######################################

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke-vnet.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke-vnet.name
}

output "spoke_subnets" {
  value = {
    for subnet_name, subnet in azurerm_subnet.spoke-subnet:
    subnet_name => subnet.id
  }
}

output "hub-to-spoke-peering" {
    value = azurerm_virtual_network_peering.hub_to_spoke_peering.id
}

output "spoke-to-hub" {
  value = azurerm_virtual_network_peering.spoke-to-hub-peering.id
}