# Helm provider for ArgoCD installation
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = null

  host                   = yamldecode(var.kube_config).clusters[0].cluster.server
  cluster_ca_certificate = base64decode(yamldecode(var.kube_config).clusters[0].cluster["certificate-authority-data"])
  client_certificate     = base64decode(yamldecode(var.kube_config).users[0].user["client-certificate-data"])
  client_key             = base64decode(yamldecode(var.kube_config).users[0].user["client-key-data"])
}

provider "helm" {
  # Configuration via environment variables or existing kubeconfig
}

# ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = {
      name = "argocd"
    }
  }
}

# ArgoCD Helm Chart installation
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.0.0"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      # Server configuration
      server = {
        service = {
          type = "LoadBalancer"
        }
        extraArgs = [
          "--insecure"  # For development - use TLS in production
        ]
      }

      # Repo server configuration
      repoServer = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      # Controller configuration
      controller = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      # Dex configuration (OIDC)
      dex = {
        enabled = false  # Simple configuration for start
      }

      # Redis configuration
      redis = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  timeout = 600

  depends_on = [kubernetes_namespace.argocd]
}