# Outputs
output "key_vault_access_granted" {
  description = "Confirmation that Key Vault access has been granted"
  value       = azurerm_role_assignment.aks_key_vault_secrets_user.id
}