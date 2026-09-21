variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "account_replication_type" {
  description = "prod: ZRS / dev: LRS を想定"
  type        = string
  default     = "LRS"
}

variable "tags" {
  type    = map(string)
  default = {}
}
