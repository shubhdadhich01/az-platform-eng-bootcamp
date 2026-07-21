output "route_table" {

 value = {
    id = azurerm_route_table.spoke_rt.id
    name = azurerm_route_table.spoke_rt.name
 }
}

output "default_route_id" {
  value = azurerm_route.egress_route.id
}