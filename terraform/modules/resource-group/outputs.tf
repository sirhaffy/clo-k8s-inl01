output "name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}