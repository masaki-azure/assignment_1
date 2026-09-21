variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "retention_in_days" {
  description = "Log Analytics のログ保持期間"
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
