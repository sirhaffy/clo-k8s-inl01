# Todo Application with Azure Kubernetes Service

A cloud-native todo application deployed on Azure Kubernetes Service (AKS) using GitOps principles with ArgoCD for continuous deployment.

## Architecture Overview

This project demonstrates a complete production-ready deployment of a .NET Core todo application with the following components:

- **Frontend**: .NET Core Web API application (todo-app)
- **Database**: MongoDB with persistent storage
- **Container Registry**: Docker Hub for image storage
- **Orchestration**: Azure Kubernetes Service (AKS)
- **GitOps**: ArgoCD for automated deployments
- **Secret Management**: Azure Key Vault with External Secrets Operator
- **Infrastructure**: Terraform for Infrastructure as Code
- **Networking**: Application Gateway for external access

## Project Structure

```
todo-app/
├── .github/workflows/       # CI/CD pipelines
├── helm/                    # Helm charts for Kubernetes deployment
│   ├── secrets/             # Secret management (Key Vault integration)
│   ├── mongodb/             # MongoDB database deployment
│   └── todo-app/            # Todo application deployment
├── argocd/                  # ArgoCD configuration files
├── terraform/               # Infrastructure as Code
└── src/                     # .NET Core application source code
```

## Deployment Architecture

The application uses a three-tier architecture deployed across separate Helm charts:

1. **Secrets Management** (sync-wave: -1)
   - Azure Key Vault integration
   - External Secrets Operator
   - Secure password management

2. **Database Layer** (sync-wave: 0)
   - MongoDB deployment with persistent storage
   - Service configuration for internal connectivity

3. **Application Layer** (sync-wave: 1)
   - .NET Core todo application
   - Ingress configuration for external access
   - Auto-scaling capabilities

## Key Features

**Infrastructure as Code**
- Complete Azure infrastructure managed through Terraform
- Automated resource provisioning and management
- Backend state storage in Azure Storage Account

**GitOps Deployment**
- ArgoCD manages all Kubernetes deployments
- Automatic synchronization with Git repository
- Self-healing deployments with drift detection

**Security**
- No hardcoded secrets in repository
- Azure Key Vault for sensitive data storage
- Managed Identity authentication
- External Secrets Operator for secure secret injection

**Automation**
- GitHub Actions for CI/CD pipelines
- Automatic Helm chart validation
- Infrastructure deployment automation
- ArgoCD Image Updater for automatic application updates

**Monitoring and Observability**
- Azure Monitor integration
- Application health checks
- Resource monitoring and alerting

## Quick Start

### Prerequisites

- Azure subscription with contributor access
- GitHub repository with required secrets configured
- Docker Hub account for image storage

### Required GitHub Secrets

```
AZURE_CREDENTIALS           # Azure service principal credentials
AZURE_LOCATION              # Azure region (e.g., North Europe)
TF_BACKEND_RESOURCE_GROUP   # Resource group for Terraform state
TF_BACKEND_STORAGE_ACCOUNT  # Storage account for Terraform state
TF_BACKEND_CONTAINER        # Container name for Terraform state
PROJECT_PREFIX              # Prefix for resource naming
```

### Deployment

1. Configure GitHub secrets according to the requirements above
2. Push changes to the master branch to trigger infrastructure deployment
3. ArgoCD will automatically deploy the application stack
4. Access the application through the Application Gateway public IP

### Manual Deployment

For manual infrastructure deployment:

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure
terraform apply

# Deploy ArgoCD applications
kubectl apply -f argocd/
```

## Development Workflow

The project follows GitOps principles with automated validation:

1. **Code Changes**: Modify Helm charts or ArgoCD configurations
2. **Validation**: GitHub Actions automatically validates all changes
3. **Infrastructure**: Terraform manages Azure resources
4. **Deployment**: ArgoCD synchronizes applications with Git state
5. **Updates**: Image Updater handles automatic application updates

## Monitoring and Maintenance

**Health Checks**
- Application health endpoints for readiness and liveness probes
- Database connectivity monitoring
- Infrastructure resource monitoring

**Automatic Updates**
- ArgoCD Image Updater monitors Docker registry for new versions
- Semver-based update strategy for controlled releases
- Automatic rollback on deployment failures

**Security Updates**
- External Secrets Operator refreshes secrets automatically
- Managed Identity rotation through Azure
- Regular security scanning through GitHub Actions

## Contributing

This project uses branch protection rules requiring:
- Pull request reviews before merging
- Successful validation of all Helm charts and YAML files
- Up-to-date branches before merging

## License

This project is part of a cloud development course and is intended for educational purposes.