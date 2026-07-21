output "firewall" {
  value = {
    id = azurerm_firewall.firewall.id
    name = azurerm_firewall.firewall.name
    private_ip = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
    public_ip = azurerm_public_ip.firewall_ip.ip_address
    policy_id = azurerm_firewall_policy.firewall_policy.id
  }
}