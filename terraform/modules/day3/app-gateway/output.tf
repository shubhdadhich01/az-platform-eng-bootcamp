output "appgw_principal_id" {
  value = azurerm_user_assigned_identity.appgw-identity.principal_id
}

# output "appgw_indentity_id" {
#   value = azurerm_user_assigned_identity.appgw-identity.id
# }

# output "appgw_subnet_id" {
#   value = azurerm_subnet.appgw-subnet.id
# }

# output "appgw_public_ip" {
#   value = azurerm_public_ip.appgw_ip.id
# }

output "backend_pool_id" {
  value = one(azurerm_application_gateway.appgw.backend_address_pool).id
}