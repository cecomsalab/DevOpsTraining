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

  # The pipeline passes the values with -backend-config.
  backend "azurerm" {}
}

# Credentials come from the ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID
# and ARM_SUBSCRIPTION_ID environment variables set by the pipeline.
provider "azurerm" {
  features {}
}
