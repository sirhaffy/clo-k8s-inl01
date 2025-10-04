# Outputs
output "id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "managed_identity_id" {
  description = "Managed Identity ID"
  value       = azurerm_user_assigned_identity.aks.id
}

output "managed_identity_principal_id" {
  description = "Managed Identity Principal ID"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "principal_id" {
  description = "Principal ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}