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

output "application_gateway_public_ip" {
  description = "Public IP address of Application Gateway"
  value       = module.application_gateway.public_ip_address
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.application_gateway.name
}

output "aks_managed_identity_id" {
  description = "AKS Managed Identity ID"
  value       = module.aks.managed_identity_id
}

output "aks_kubelet_identity_object_id" {
  description = "AKS Kubelet Identity Object ID"
  value       = module.aks.kubelet_identity_object_id
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
    check_autoscaling  = "az aks nodepool show --cluster-name ${module.aks.cluster_name} --resource-group ${module.resource_group.name} --name default"
    deploy_mongodb     = "helm repo add bitnami https://charts.bitnami.com/bitnami && helm install mongodb bitnami/mongodb --namespace default"
    access_todo_app    = "curl -H 'Host: localhost' http://${module.application_gateway.public_ip_address}"
  }
}

# Instructions for next steps
output "next_steps" {
  description = "Instructions for accessing and using the deployed infrastructure"
  value = <<-EOT

    Azure Infrastructure deployed successfully!

    Application Gateway Public IP: ${module.application_gateway.public_ip_address}
    AKS Auto-scaling: Enabled (Min: 2, Max: 5 nodes)

    Next Steps:

    1. Connect to AKS cluster:
       ${join("\n       ", [
         "az aks get-credentials --resource-group ${module.resource_group.name} --name ${module.aks.cluster_name}",
         "kubectl get nodes"
       ])}

    2. Access Todo App:
       ${join("\n       ", [
         "curl -H 'Host: localhost' http://${module.application_gateway.public_ip_address}",
         "# Or open in browser: http://${module.application_gateway.public_ip_address}"
       ])}

    3. Check auto-scaling status:
       ${join("\n       ", [
         "az aks nodepool show --cluster-name ${module.aks.cluster_name} --resource-group ${module.resource_group.name} --name default",
         "kubectl get nodes -w  # Watch nodes scale"
       ])}

    4. Update Key Vault secrets:
       # Go to Azure Portal -> ${module.key_vault.name} -> Secrets
       # Update: mongodb-connection-string, dockerhub-token

    Key Vault: ${module.key_vault.vault_uri}
    Monitoring: Check Azure Portal for Log Analytics and Application Insights

    Note: ArgoCD will be installed automatically via GitHub Actions workflow

  EOT
}