# Outputs
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_key" {
  description = "Primary access key for storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "file_share_backups_name" {
  description = "Name of the MongoDB backups file share"
  value       = azurerm_storage_share.mongodb_backups.name
}