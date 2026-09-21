variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "address_space" {
  description = "VNet全体のアドレス空間"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_containerapps_prefix" {
  description = "Container Apps環境のVNet統合用サブネット"
  type        = list(string)
  default     = ["10.0.0.0/23"]
}

variable "subnet_pe_prefix" {
  description = "PostgreSQL Private Endpoint専用サブネット"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
