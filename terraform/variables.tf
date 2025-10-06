# Terraform variables - can be overridden with terraform.tfvars or -var flags

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "todo-app"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West Europe"

  validation {
    condition = contains([
      "West Europe", "North Europe", "East US", "West US", "Central US",
      "Southeast Asia", "East Asia", "UK South", "Australia East"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "todo-app-aks"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1

  validation {
    condition     = var.min_node_count >= 1 && var.min_node_count <= 5
    error_message = "Minimum node count must be between 1 and 5."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5

  validation {
    condition     = var.max_node_count >= var.min_node_count && var.max_node_count <= 10
    error_message = "Maximum node count must be greater than or equal to minimum node count and not exceed 10."
  }
}

variable "vm_size" {
  description = "Size of the VMs in the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.28.9"
}