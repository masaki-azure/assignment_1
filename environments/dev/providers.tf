terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-health-dev"
    storage_account_name = "sthealthtfstatedev"
    container_name        = "tfstate"
    key                    = "dev.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}
