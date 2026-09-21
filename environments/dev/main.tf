# 対象のリソースグループはbootstrapで作成済みのため、ここでは参照のみ行う。
data "azurerm_resource_group" "this" {
  name = "rg-health-dev"
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  environment         = local.environment
  tags                = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  environment         = local.environment
  retention_in_days   = 30
  tags                = local.tags
}

module "security" {
  source                   = "../../modules/security"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  environment              = local.environment
  tenant_id                = var.tenant_id
  purge_protection_enabled = false
  tags                     = local.tags
}

module "storage" {
  source                   = "../../modules/storage"
  name_suffix              = random_string.suffix.result
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  environment              = local.environment
  account_replication_type = "LRS"
  tags                     = local.tags
}

module "data" {
  source                     = "../../modules/data"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = data.azurerm_resource_group.this.location
  environment                = local.environment
  sku_name                   = "GP_Standard_D2s_v3"
  high_availability_enabled  = false
  subnet_private_endpoint_id = module.network.subnet_private_endpoint_id
  private_dns_zone_id        = module.network.private_dns_zone_id
  administrator_login        = var.administrator_login
  administrator_password     = var.administrator_password
  tags                       = local.tags
}

module "app" {
  source                     = "../../modules/app"
  resource_group_name        = data.azurerm_resource_group.this.name
  location                   = data.azurerm_resource_group.this.location
  environment                = local.environment
  subnet_containerapps_id    = module.network.subnet_containerapps_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  zone_redundant             = false
  key_vault_id               = module.security.key_vault_id
  key_vault_uri              = module.security.key_vault_uri
  storage_account_id         = module.storage.storage_account_id
  storage_account_name       = module.storage.storage_account_name
  container_image            = var.container_image
  min_replicas               = 0
  max_replicas               = 2
  tags                       = local.tags
}

module "edge" {
  source              = "../../modules/edge"
  resource_group_name = data.azurerm_resource_group.this.name
  environment         = local.environment
  sku_name            = "Standard_AzureFrontDoor"
  origin_host_name    = module.app.container_app_fqdn
  tags                = local.tags
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
