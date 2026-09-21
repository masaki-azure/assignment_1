# RBAC割り当ては本モジュールでは行わない
# Container AppsのManaged Identityに対する権限付与は modules/app 側に集約する

# TODO: Key Vault名は環境名だけでは衝突する可能性があるため、実装時にサフィックス付与を検討。
resource "azurerm_key_vault" "this" {
  name                = "kv-health-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled = true
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = 7

  # TODO: Container Apps (Consumption) は Egress IP が動的なため、
  # ネットワークレベルの Firewall (Deny) は実質機能しない
  # そのため Allow とし、防御線は Managed Identity による RBAC 認可に一任する
  # tfsec:ignore:azure-keyvault-specify-network-acl
  # tfsec:ignore:azure-keyvault-no-purge
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}
