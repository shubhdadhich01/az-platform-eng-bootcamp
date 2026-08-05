output "initiative_id" {
  value = azurerm_policy_set_definition.northwind_baseline.id
}

output "assignment_id" {
  value = azurerm_resource_group_policy_assignment.baseline.id
}