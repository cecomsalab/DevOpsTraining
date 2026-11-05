output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  description = "IDs of the subnets."
  value = {
    web  = azurerm_subnet.web.id
    data = azurerm_subnet.data.id
  }
}

output "storage_account_name" {
  description = "Globally unique name of the storage account."
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Blob endpoint of the storage account."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}
