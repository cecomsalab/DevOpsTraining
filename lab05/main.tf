data "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}

locals {
  name     = "${var.prefix}-lab05"
  location = data.azurerm_resource_group.lab.location
  tags = {
    course      = "devops"
    lab         = "05"
    environment = "lab"
  }

  # Each subnet is a /24 inside the /16 address space.
  subnet_prefixes = {
    for name, index in var.subnets : name => cidrsubnet(var.address_space, 8, index)
  }
}

module "network" {
  source = "./modules/network"

  name                = "vnet-${local.name}"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.lab.name
  address_space       = [var.address_space]
  subnets             = local.subnet_prefixes
  tags                = local.tags
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-${local.name}-web"
  location            = local.location
  resource_group_name = data.azurerm_resource_group.lab.name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = {
      ssh = { priority = 100, port = "22", source = var.allowed_ssh_cidr }
    }
    content {
      name                       = "allow-${security_rule.key}"
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = security_rule.value.source
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = module.network.subnet_ids["web"]
  network_security_group_id = azurerm_network_security_group.web.id
}
