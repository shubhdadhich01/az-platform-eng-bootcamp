output "web_vm" {
  value = {
    id = azurerm_linux_virtual_machine.web-vm.id
    name = azurerm_linux_virtual_machine.web-vm.name
    private_ip = azurerm_network_interface.web-nic.private_ip_address
  }
}

output "app_vm" {
  value = {
    id = azurerm_linux_virtual_machine.app-vm.id
    name = azurerm_linux_virtual_machine.app-vm.name
    private_ip = azurerm_network_interface.app-nic.private_ip_address
  }
}

output "app_vm_principal_id" {
  value = azurerm_linux_virtual_machine.app-vm.identity[0].principal_id
}

output "ansible_worker" {
  value = {
    web = {
        name = azurerm_linux_virtual_machine.web-vm.name
        private_ip = azurerm_network_interface.web-nic.private_ip_address
    }

    app = {
        name = azurerm_linux_virtual_machine.app-vm.name
        private_ip = azurerm_network_interface.app-nic.private_ip_address
    }
  }
}