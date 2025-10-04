variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Storage Account for MongoDB backups and config
# NOT for application persistent storage - todo-app is stateless!
resource "azurerm_storage_account" "main" {
  name                     = "st${replace(var.naming_prefix, "-", "")}"
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  # Security settings
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  min_tls_version                = "TLS1_2"

  # Network rules
  network_rules {
    default_action = "Allow"  # "Deny" for production with private endpoints
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# File Share for MongoDB backups (optional)
resource "azurerm_storage_share" "mongodb_backups" {
  name               = "mongodb-backups"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 20  # 20 GB for backups

  metadata = {
    purpose = "MongoDB database backups"
  }
}

# Storage Classes for AKS (definitions for different types of disk storage)
# These are created automatically by AKS but we can define custom ones

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