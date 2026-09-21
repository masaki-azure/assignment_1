resource "azurerm_container_app_environment" "this" {
  name                       = "cae-health-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  infrastructure_subnet_id   = var.subnet_containerapps_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  zone_redundancy_enabled    = var.zone_redundant

  tags = var.tags
}

resource "azurerm_container_app" "this" {
  name                         = "ca-health-${var.environment}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  ingress {
    external_enabled = true
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "app"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      env {
        name  = "AZURE_KEY_VAULT_URI"
        value = var.key_vault_uri
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }
    }
  }
  tags = var.tags
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_container_app.this.identity[0].principal_id
}
