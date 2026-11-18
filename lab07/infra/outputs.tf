output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Subnet IDs by name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.main.name
}
