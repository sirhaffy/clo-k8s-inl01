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