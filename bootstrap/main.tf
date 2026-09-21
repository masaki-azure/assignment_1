# 環境ごとに以下を作成する。
#   - アプリ用リソースグループ（rg-health-dev / rg-health-prod）
#   - tfstate 保存用 Storage Account（環境ごとに分離。RG は同居させる）
#   - tfstate 用コンテナ
#
# 通常の CI/CD パイプラインには乗らない。実行者が手動で一度だけ apply する
# 前提のコードであり、アプリ本体のリソースは一切含まない。

locals {
  environments = toset(var.environments)
}

resource "azurerm_resource_group" "this" {
  for_each = local.environments

  name     = "rg-${var.project}-${each.key}"
  location = var.location

  tags = merge(var.common_tags, {
    environment = each.key
    managed-by  = "terraform"
  })
}

resource "azurerm_storage_account" "tfstate" {
  for_each = local.environments

  name                 = "st${var.project}tfstate${each.key}"
  resource_group_name  = azurerm_resource_group.this[each.key].name
  location             = azurerm_resource_group.this[each.key].location

  account_tier              = "Standard"
  account_replication_type  = "LRS"
  min_tls_version           = "TLS1_2"

  shared_access_key_enabled = true

  tags = merge(var.common_tags, {
    environment = each.key
    managed-by  = "terraform"
    purpose     = "tfstate"
  })
}

resource "azurerm_storage_container" "tfstate" {
  for_each = local.environments
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate[each.key].id
  container_access_type = "private"
}
