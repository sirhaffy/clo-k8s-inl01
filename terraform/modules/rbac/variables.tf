variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "aks_principal_id" {
  description = "AKS managed identity principal ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID"
  type        = string
}

variable "aks_kubelet_identity_object_id" {
  description = "AKS kubelet identity object ID for Key Vault access"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}