variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "kube_config" {
  description = "Kubernetes configuration"
  type        = string
  sensitive   = true
}