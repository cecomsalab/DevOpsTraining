output "subnet_ids" {
  description = "Subnet IDs returned by the network module."
  value       = module.network.subnet_ids
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine."
  value       = azurerm_public_ip.vm.ip_address
}

output "ssh_command" {
  description = "Command to connect to the virtual machine."
  value       = "ssh -i ~/.ssh/lab05_ed25519 ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}
