output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_containerapps_id" {
  value = azurerm_subnet.containerapps.id
}

output "subnet_private_endpoint_id" {
  value = azurerm_subnet.private_endpoint.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.postgres.id
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.postgres.name
}
