variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_containerapps_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "zone_redundant" {
  description = "prod: true / dev: false"
  type        = bool
  default     = false
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "target_port" {
  type    = number
  default = 8080
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "memory" {
  type    = string
  default = "1Gi"
}

variable "min_replicas" {
  type    = number
  default = 0
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}
