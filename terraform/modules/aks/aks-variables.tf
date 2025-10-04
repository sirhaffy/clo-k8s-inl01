variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "naming_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for AKS cluster"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for secrets integration"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29.2"
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_B4ms"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}