output "bastion" {
  value = {
    id = azurerm_bastion_host.bastion.id
    name = azurerm_bastion_host.bastion.name
    public_ip = azurerm_public_ip.bastion_ip.ip_address
  }
}