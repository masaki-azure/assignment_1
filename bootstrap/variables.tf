variable "location" {
  description = "リソースを作成する Azure リージョン"
  type        = string
  default     = "japaneast"
}

variable "project" {
  description = "プロジェクト名。リソース命名規則のプレフィックスとして使用する"
  type        = string
  default     = "health"
}

variable "environments" {
  description = "作成する環境の一覧。dev/prod それぞれの RG と tfstate 用 Storage Account を作成する"
  type        = list(string)
  default     = ["dev", "prod"]
}

variable "common_tags" {
  description = "全リソースに共通で付与するタグ"
  type        = map(string)
  default = {
    project = "health-app"
  }
}
