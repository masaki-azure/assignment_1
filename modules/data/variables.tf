variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "GP_Standard_D2s_v3"
}

variable "storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "high_availability_enabled" {
  description = "prod: true（Zone Redundant HA） / dev: false"
  type        = bool
  default     = false
}

variable "zone" {
  type    = string
  default = "1"
}

variable "standby_availability_zone" {
  type    = string
  default = "2"
}

variable "subnet_private_endpoint_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_password" {
  # TODO: 平文変数での受け渡しは暫定
  # 実運用ではKey Vaultで生成・管理したものをCI/CDのSecrets経由で注入する想定
  type      = string
  sensitive = true
}

variable "database_name" {
  type    = string
  default = "healthapp"
}

variable "tags" {
  type    = map(string)
  default = {}
}
