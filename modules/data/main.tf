# Public Network Access は無効化し、Private Endpoint経由のみでアクセスさせる。

resource "azurerm_postgresql_flexible_server" "this" {
  name                = "psql-health-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  version    = var.postgres_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  public_network_access_enabled = false

  zone = var.zone

  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_availability_zone
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-psql-health-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_private_endpoint_id

  private_service_connection {
    name                           = "psc-psql-health-${var.environment}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
