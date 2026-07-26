resource "time_sleep" "wait_for_rbac" {
  create_duration = "90s"
}

resource "azurerm_role_assignment" "ansible_reader" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.ansible-vm.identity[0].principal_id
}