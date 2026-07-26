output "web_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.web-vmss.id
}

output "web_vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.web-vmss.name
}