data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

locals {
  name     = "${var.prefix}-lab07"
  location = data.azurerm_resource_group.lab.location
  tags = {
    course      = "devops"
    lab         = "07"
    managed_by  = "terraform"
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.lab.name
  address_space       = [var.address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, each.value)]
}

resource "azurerm_storage_account" "main" {
  name                     = "st${var.prefix}${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.lab.name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}
