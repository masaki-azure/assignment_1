output "resource_group_names" {
  description = "作成したリソースグループ名（環境名をキーとするマップ）"
  value       = { for env, rg in azurerm_resource_group.this : env => rg.name }
}

output "tfstate_storage_account_names" {
  description = "tfstate 保存用 Storage Account 名（環境名をキーとするマップ）。各環境の backend 設定（environments/{env}/backend.tf）で使用する"
  value       = { for env, sa in azurerm_storage_account.tfstate : env => sa.name }
}

output "tfstate_container_name" {
  description = "tfstate 保存用コンテナ名（全環境共通）"
  value       = "tfstate"
}
