# Outputs
output "id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "secrets" {
  description = "Map of created secrets"
  value = {
    mongodb_root_password = azurerm_key_vault_secret.mongodb_root_password.name
    mongodb_database      = azurerm_key_vault_secret.mongodb_database.name
    mongodb_connection    = azurerm_key_vault_secret.mongodb_connection.name
    dockerhub_username    = azurerm_key_vault_secret.dockerhub_username.name
    dockerhub_token       = azurerm_key_vault_secret.dockerhub_token.name
  }
}

output "mongodb_password" {
  description = "Generated MongoDB password"
  value       = random_password.mongodb_password.result
  sensitive   = true
}