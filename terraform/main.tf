# Root Terraform configuration with modular structure
terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    use_azuread_auth = false  # Use Service Principal authentication for GitHub Actions
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  # Service Principal authentication for GitHub Actions
  use_cli                = false
  use_msi                = false

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Local values for consistent naming
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.naming_prefix
    ManagedBy   = "terraform"
    Owner       = "haffy"
  }
}

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Networking Module (VNet, Subnets, NSGs)
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = var.naming_prefix
  tags              = local.common_tags
}

# Key Vault Module (Secret Manager)
module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name              = module.resource_group.name
  location                        = module.resource_group.location
  naming_prefix                   = var.naming_prefix
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  object_id                       = data.azurerm_client_config.current.object_id
  aks_managed_identity_object_id  = module.aks.kubelet_identity_object_id
  tags                           = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = var.naming_prefix
  tags              = local.common_tags
}

# Storage Module (Azure Storage Account & File Shares)
module "storage" {
  source = "./modules/storage"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = var.naming_prefix
  tags              = local.common_tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name     = module.resource_group.name
  location               = module.resource_group.location
  naming_prefix          = var.naming_prefix
  subnet_id             = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  key_vault_id          = module.key_vault.id
  tags                  = local.common_tags

  # AKS configuration
  kubernetes_version     = var.kubernetes_version
  min_node_count        = var.min_node_count
  max_node_count        = var.max_node_count
  vm_size               = var.vm_size
  admin_group_object_ids = []
}

# RBAC Module
module "rbac" {
  source = "./modules/rbac"

  resource_group_name = module.resource_group.name
  aks_principal_id   = module.aks.principal_id
  key_vault_id       = module.key_vault.id
}

# Application Gateway Module
module "application_gateway" {
  source = "./modules/application-gateway"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = var.naming_prefix
  appgw_subnet_id    = module.networking.appgw_subnet_id
  tags              = local.common_tags
}