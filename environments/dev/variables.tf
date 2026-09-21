variable "tenant_id" {
  type = string
}

variable "administrator_login" {
  type    = string
  default = "psqladmin"
}

variable "administrator_password" {
  # TODO: 平文管理は暫定。実運用ではGitHub Secretsから注入する。
  type      = string
  sensitive = true
}

variable "container_image" {
  type = string
  # TODO: 実際のコンテナイメージ（ACR等）が確定次第、値を差し替える。
  default = "mcr.microsoft.com/azuredocs/xxxxxx-xxxxx:1.0.0"
}

locals {
  environment = "dev"
  tags = {
    project     = "health-app"
    environment = "dev"
    managed-by  = "terraform"
    owner       = "infra-team"
  }
}
