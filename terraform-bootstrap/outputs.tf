# Outputs for the bootstrap configuration
output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.terraform_state.name
}

output "container_name" {
  description = "Name of the storage container for Terraform state"
  value       = azurerm_storage_container.terraform_state.name
}

output "resource_group_name" {
  description = "Name of the resource group containing state storage"
  value       = azurerm_resource_group.terraform_state.name
}

output "key_vault_name" {
  description = "Name of the Key Vault for Terraform secrets"
  value       = azurerm_key_vault.terraform_secrets.name
}

output "backend_config" {
  description = "Backend configuration for main Terraform project"
  value = {
    resource_group_name  = azurerm_resource_group.terraform_state.name
    storage_account_name = azurerm_storage_account.terraform_state.name
    container_name       = azurerm_storage_container.terraform_state.name
    key                  = "todo-app/terraform.tfstate"
  }
}

# Instructions for setup
output "setup_instructions" {
  description = "Instructions for setting up the main Terraform project"
  value = <<EOT
1. Run this bootstrap once to create state storage:
   terraform init
   terraform apply

2. Update main terraform/backend.tf with these values:
   resource_group_name  = "${azurerm_resource_group.terraform_state.name}"
   storage_account_name = "${azurerm_storage_account.terraform_state.name}"
   container_name       = "${azurerm_storage_container.terraform_state.name}"

3. Initialize main project with backend:
   cd ../terraform
   terraform init -migrate-state

4. Backend is now configured with state locking!
EOT
}