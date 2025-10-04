# Outputs
output "id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.main.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw.ip_address
}

output "managed_identity_id" {
  description = "Managed Identity ID"
  value       = azurerm_user_assigned_identity.appgw.id
}

output "managed_identity_principal_id" {
  description = "Managed Identity Principal ID"
  value       = azurerm_user_assigned_identity.appgw.principal_id
}