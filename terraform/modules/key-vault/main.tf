# Random suffix for unique Key Vault name
resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Random password for MongoDB (generated securely)
resource "random_password" "mongodb_password" {
  length  = 16
  special = true
}

# Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                = "kv-${replace(var.naming_prefix, "-", "")}${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # Säkerhetsinställningar
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = false # True for production
  soft_delete_retention_days      = 7     # 90 for production

  # Network ACLs
  network_acls {
    default_action = "Allow"  # "Deny" for production with private endpoints
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Access Policy for current user/service principal
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get",
    "Import", "List", "Purge", "Recover", "Restore", "Sign",
    "UnwrapKey", "Update", "Verify", "WrapKey", "Release",
    "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge",
    "Recover", "Restore", "Set"
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get",
    "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts",
    "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
}

# Standard secrets for todo-app
resource "azurerm_key_vault_secret" "mongodb_root_password" {
  name         = "mongodb-root-password"
  value        = random_password.mongodb_password.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_key_vault_secret" "mongodb_database" {
  name         = "mongodb-database"
  value        = "TodoApp"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_key_vault_secret" "mongodb_connection" {
  name         = "mongodb-connection-string"
  value        = "mongodb://root:${random_password.mongodb_password.result}@todo-app-mongodb-service:27017/TodoApp?authSource=admin"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_key_vault_secret" "dockerhub_username" {
  name         = "dockerhub-username"
  value        = "haffy"  # Ditt DockerHub username
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_key_vault_secret" "dockerhub_token" {
  name         = "dockerhub-token"
  value        = "change-me-in-azure-portal"  # Ändra i Azure Portal
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}