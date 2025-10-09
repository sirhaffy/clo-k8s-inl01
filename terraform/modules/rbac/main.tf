# RBAC for AKS - Key Vault Secrets User
resource "azurerm_role_assignment" "aks_key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.aks_principal_id
}

# RBAC for AKS - Managed Identity Operator (for CSI driver)
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "aks_managed_identity_operator" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_principal_id
}

# Key Vault Access Policy for AKS Kubelet Identity
resource "azurerm_key_vault_access_policy" "aks_kubelet_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = var.aks_kubelet_identity_object_id

  secret_permissions = [
    "Get", "List"
  ]
}