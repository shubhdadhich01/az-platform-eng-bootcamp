output "sa_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sa-private-dns.id
}

output "kv_private_dns_zone_id" {
  value = azurerm_private_dns_zone.kv-private-dns.id
}