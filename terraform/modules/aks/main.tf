# User Assigned Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "uai-${var.naming_prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# RBAC for Managed Identity - Network Contributor on subnet
resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# RBAC for Key Vault Secrets User
resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.naming_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.naming_prefix}"
  kubernetes_version  = var.kubernetes_version

  # Default node pool
  default_node_pool {
    name           = "default"
    vm_size        = var.vm_size
    vnet_subnet_id = var.subnet_id
    node_count     = var.min_node_count

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Managed Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Network profile
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = "10.2.0.10"
    service_cidr      = "10.2.0.0/24"
    load_balancer_sku = "standard"
  }

  # Monitoring
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # Azure Active Directory integration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }

  # Security settings
  role_based_access_control_enabled = true

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.network_contributor,
    azurerm_role_assignment.key_vault_secrets_user
  ]
}

