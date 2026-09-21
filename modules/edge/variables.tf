variable "resource_group_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "sku_name" {
  description = "prod: Premium_AzureFrontDoor / dev: Standard_AzureFrontDoor"
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "origin_host_name" {
  description = "Container AppsのFQDN"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
