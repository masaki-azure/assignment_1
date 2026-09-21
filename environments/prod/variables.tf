variable "tenant_id" {
  type = string
}

variable "administrator_login" {
  type    = string
  default = "psqladmin"
}

variable "administrator_password" {
  type      = string
  sensitive = true
}

variable "container_image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

locals {
  environment = "prod"
  tags = {
    project     = "health-app"
    environment = "prod"
    managed-by  = "terraform"
    owner       = "infra-team"
  }
}
