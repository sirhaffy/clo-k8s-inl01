variable "resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
  default     = "rg_clo_k8s_inl01"
}

variable "location" {
  description = "Azure region for Terraform state resources"
  type        = string
  default     = "northeurope"
}

variable "storage_account_name" {
  description = "Name of the storage account for Terraform state (must be globally unique)"
  type        = string
  default     = "stclok8sinl01tfstate"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "clo-k8s-inl01"
}

variable "container_name" {
  description = "Name of the storage container for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
  default     = "kv-clo-k8s-inl01-tfstate"
}