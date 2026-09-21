output "container_app_principal_id" {
  value = azurerm_container_app.this.identity[0].principal_id
}

output "container_app_fqdn" {
  value = azurerm_container_app.this.latest_revision_fqdn
}
