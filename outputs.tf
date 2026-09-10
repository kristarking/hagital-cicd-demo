output "vm_public_ip" {
  description = "Public IP VM"
  value       = azurerm_public_ip.hagital-ip.ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.hagital-rg.name
}