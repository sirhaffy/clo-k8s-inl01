# Terraform Bootstrap - Creates backend infrastructure for state storage
terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group for Terraform state storage
resource "azurerm_resource_group" "terraform_state" {
  name     = "rg_clo_k8s_inl01"
  location = "North Europe"

  tags = {
    Environment = "shared"
    Purpose     = "terraform-state"
    Project     = "clo-k8s-inl01"
  }
}

# Storage Account for Terraform state
resource "azurerm_storage_account" "terraform_state" {
  name                     = "stclok8sinl01tfstate"
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false  # Use Azure AD authentication

  # Enable versioning for state file recovery
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = {
    Environment = "shared"
    Purpose     = "terraform-state"
    Project     = "todo-app"
  }
}

# Storage Container for Terraform state files
resource "azurerm_storage_container" "terraform_state" {
  name                 = "tfstate"
  storage_account_id   = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
}

# Role assignment for GitHub Actions Service Principal
# This allows GitHub Actions to read/write state files
data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "terraform_state_contributor" {
  scope                = azurerm_storage_account.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Optional: Key Vault for storing sensitive Terraform outputs
resource "azurerm_key_vault" "terraform_secrets" {
  name                = "kv-terraform-secrets"
  location            = azurerm_resource_group.terraform_state.location
  resource_group_name = azurerm_resource_group.terraform_state.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable for deployment, template deployment, and disk encryption
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true

  # Purge protection for production (disabled for dev/testing)
  purge_protection_enabled = false
  soft_delete_retention_days = 7

  # Network access
  network_acls {
    default_action = "Allow"  # "Deny" for production with private endpoints
    bypass         = "AzureServices"
  }

  tags = {
    Environment = "shared"
    Purpose     = "terraform-secrets"
    Project     = "todo-app"
  }
}

# Access policy for current user/service principal
resource "azurerm_key_vault_access_policy" "terraform_secrets" {
  key_vault_id = azurerm_key_vault.terraform_secrets.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
  ]

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"
  ]
}