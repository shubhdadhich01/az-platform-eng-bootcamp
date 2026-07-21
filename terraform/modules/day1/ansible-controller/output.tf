output "ansible-Controller" {
  value = {
    id         = azurerm_linux_virtual_machine.ansible-vm.id
    name       = azurerm_linux_virtual_machine.ansible-vm.name
    private_ip = azurerm_network_interface.ansible-nic.private_ip_address
  }
}
