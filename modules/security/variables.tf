variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "purge_protection_enabled" {
  description = "誤削除防止（prodではtrue推奨、devはfalseでコスト・スピード優先も可）"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
