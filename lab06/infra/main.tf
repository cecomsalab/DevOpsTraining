# The resource group already exists and is managed outside Terraform,
# so it is read with a data source instead of being created.
data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

locals {
  name     = "${var.prefix}-lab04"
  location = data.azurerm_resource_group.lab.location
  tags     = merge(var.tags, { course = "devops", lab = "04" })
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.lab.name
  address_space       = var.address_space
  tags                = local.tags
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = data.azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.2.0/24"]
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
