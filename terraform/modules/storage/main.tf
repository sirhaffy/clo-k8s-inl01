# Random suffix for globally unique storage account name
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Storage Account for MongoDB backups and configuration files.
resource "azurerm_storage_account" "main" {
  name                     = "st${replace(var.naming_prefix, "-", "")}${random_string.storage_suffix.result}"
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
  name                 = "mongodb-backups"
#   storage_account_name = azurerm_storage_account.main.name <-- Depricated
  storage_account_id   = azurerm_storage_account.main.id
  quota                = 20  # 20 GB for backups
}
