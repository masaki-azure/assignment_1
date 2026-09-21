# クライアントからの直接アクセスは想定せず、Container Apps経由でのみ利用する。
# RBAC割り当ては本モジュールでは行わない

# TODO: Storage Account名は衝突する可能性があるため、実装時にサフィックス付与を検討

# Managed Identity + RBAC のみでアクセスさせるため、アカウントキーは無効化する。
resource "azurerm_storage_account" "this" {
  name                = "sthealth${var.environment}${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  min_tls_version          = "TLS1_2"

  shared_access_key_enabled = false

  tags = var.tags
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
