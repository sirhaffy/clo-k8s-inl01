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

variable "appgw_subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "aks_subnet_id" {
  description = "Subnet ID for AKS nodes (for backend discovery)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}