#########################################################
# Spoke Route Table
#########################################################

resource "azurerm_route_table" "spoke_rt" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = var.tags
}

#########################################################
# Default Route Through Azure Firewall
#########################################################

resource "azurerm_route" "egress_route" {
  name                   = "egress-route-via-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.spoke_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

#########################################################
# Associate Route Table With Spoke Subnets
#########################################################

resource "azurerm_subnet_route_table_association" "spoke_rt_association" {
  for_each       = var.spoke_subnet_ids
  subnet_id      = each.value
  route_table_id = azurerm_route_table.spoke_rt.id
}