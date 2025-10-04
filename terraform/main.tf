# Root Terraform configuration with modular structure
terraform {
  required_version = ">= 1.0"

  # Backend configuration for remote state storage
  # Dynamic values provided via terraform init -backend-config:
  # - resource_group_name=rg-terraform-state
  # - storage_account_name=sttodoterraformstate
  # - container_name=tfstate
  # - key={environment}/terraform.tfstate
  backend "azurerm" {
    # Will use storage account access keys (enabled in bootstrap)
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
    Project     = "todo-app"
    ManagedBy   = "terraform"
    Owner       = "haffy"
  }

  naming_prefix = "${var.project_name}-${var.environment}"
}

# Resource Group Module
module "resource_group" {
  source = "./modules/resource-group"

  name     = "rg-${local.naming_prefix}"
  location = var.location
  tags     = local.common_tags
}

# Networking Module (VNet, Subnets, NSGs)
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = local.naming_prefix
  tags              = local.common_tags
}

# Key Vault Module (Secret Manager)
module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = local.naming_prefix
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  tags              = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = local.naming_prefix
  tags              = local.common_tags
}

# Storage Module (Azure Storage Account & File Shares)
module "storage" {
  source = "./modules/storage"

  resource_group_name = module.resource_group.name
  location           = module.resource_group.location
  naming_prefix      = local.naming_prefix
  tags              = local.common_tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name     = module.resource_group.name
  location               = module.resource_group.location
  naming_prefix          = local.naming_prefix
  subnet_id             = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.workspace_id
  key_vault_id          = module.key_vault.id
  tags                  = local.common_tags

  # AKS configuration
  kubernetes_version = var.kubernetes_version
  node_count        = var.node_count
  vm_size          = var.vm_size
}

# RBAC Module
module "rbac" {
  source = "./modules/rbac"

  resource_group_name = module.resource_group.name
  aks_principal_id   = module.aks.principal_id
  key_vault_id       = module.key_vault.id
}

# ArgoCD Module
module "argocd" {
  source = "./modules/argocd"

  cluster_name           = module.aks.cluster_name
  resource_group_name    = module.resource_group.name
  kube_config           = module.aks.kube_config
}