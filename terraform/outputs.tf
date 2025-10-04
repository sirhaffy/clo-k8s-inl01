# Terraform outputs to show important resource information

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitoring.workspace_name
}

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = module.storage.storage_account_name
}

output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = module.argocd.namespace
}

# Sensitive outputs
output "kube_config" {
  description = "Kubernetes configuration for kubectl access"
  value       = module.aks.kube_config
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.instrumentation_key
  sensitive   = true
}

# Commands to connect to the cluster
output "connect_commands" {
  description = "Commands to connect to the AKS cluster and access services"
  value = {
    az_login           = "az login"
    get_credentials    = "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name}"
    check_nodes        = "kubectl get nodes"
    argocd_password    = "kubectl -n ${module.argocd.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    argocd_port_forward = "kubectl port-forward svc/argocd-server -n ${module.argocd.namespace} 8080:443"
    deploy_mongodb     = "helm repo add bitnami https://charts.bitnami.com/bitnami && helm install mongodb bitnami/mongodb --namespace default"
  }
}

# Instructions for next steps
output "next_steps" {
  description = "Instructions for accessing and using the deployed infrastructure"
  value = <<-EOT

    🚀 Azure Infrastructure deployed successfully!

    📋 Next Steps:

    1. Connect to AKS cluster:
       ${join("\n       ", [
         "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name}",
         "kubectl get nodes"
       ])}

    2. Access ArgoCD:
       ${join("\n       ", [
         "kubectl port-forward svc/argocd-server -n ${module.argocd.namespace} 8080:443",
         "# Default admin password:",
         "kubectl get secret argocd-initial-admin-secret -n ${module.argocd.namespace} -o jsonpath=\"{.data.password}\" | base64 -d"
       ])}

    3. Update Key Vault secrets:
       # Go to Azure Portal -> ${module.key_vault.name} -> Secrets
       # Update: mongodb-connection-string, dockerhub-token

    4. Deploy MongoDB:
       ${join("\n       ", [
         "helm repo add bitnami https://charts.bitnami.com/bitnami",
         "helm install mongodb bitnami/mongodb --namespace default"
       ])}

    5. Configure ArgoCD Application for todo-app Helm chart

    🔐 Key Vault: ${module.key_vault.vault_uri}
    📊 Monitoring: Check Azure Portal for Log Analytics and Application Insights

  EOT
}

# AKS cluster kubeconfig for CI/CD
output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}