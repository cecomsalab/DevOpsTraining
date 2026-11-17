terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Exercise 3 of the lab: remove the comment character from the backend line.
  # Partial configuration: the values come from backend.hcl
  #   terraform init -backend-config=backend.hcl -migrate-state
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
