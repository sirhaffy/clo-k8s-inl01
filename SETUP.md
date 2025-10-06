# Setup Instructions - Terraform Backend Infrastructure

Kör dessa kommandon INNAN CI/CD workflow:en kan köra.

## 1. Skapa Service Principal

```bash
# Skapa Service Principal för GitHub Actions
az ad sp create-for-rbac --name "github-actions-clo-k8s-inl01" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --json-auth

# Spara output som GitHub Secret: AZURE_CREDENTIALS
```

## 2. Skapa Backend Infrastructure

```bash
# Sätt variabler
RESOURCE_GROUP="rg-clo-k8s-inl01-tfstate"
STORAGE_ACCOUNT="stclok8sinl01tfstate"
CONTAINER_NAME="tfstate"
LOCATION="West Europe"
KEY_VAULT_NAME="kv-clo-k8s-inl01-tfstate"

# Skapa Resource Group
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Skapa Storage Account med Azure AD authentication
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --allow-blob-public-access false \
  --shared-access-key-enabled false

# Skapa Storage Container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Skapa Key Vault för secrets
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION"

# Ge Service Principal access till Storage Account
SP_OBJECT_ID=$(az ad sp show --id "YOUR_SERVICE_PRINCIPAL_CLIENT_ID" --query id -o tsv)
az role assignment create \
  --assignee $SP_OBJECT_ID \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT"
```

## 3. Konfigurera GitHub Secrets

Lägg till dessa secrets i GitHub repository:

```
AZURE_CREDENTIALS           # JSON från Service Principal creation
AZURE_LOCATION              # West Europe
PROJECT_PREFIX               # clo-k8s-inl01
TF_BACKEND_RESOURCE_GROUP   # rg-clo-k8s-inl01-tfstate
TF_BACKEND_STORAGE_ACCOUNT  # stclok8sinl01tfstate
TF_BACKEND_CONTAINER        # tfstate
```

## 4. Terraform State Storage

**State lagras i:**
- **Storage Account:** `stclok8sinl01tfstate`
- **Container:** `tfstate`
- **Fil:** `{environment}/terraform.tfstate` (t.ex. `dev/terraform.tfstate`)
- **Authentication:** Azure AD (use_azuread_auth = true)

## 5. Verifiera Setup

```bash
# Kontrollera att allt är skapat
az group show --name $RESOURCE_GROUP
az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP
az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --auth-mode login
az keyvault show --name $KEY_VAULT_NAME
```

## 6. Kör CI/CD

Nu kan GitHub Actions workflow köras - den kommer automatiskt att:
1. Använda befintlig backend infrastructure
2. Lagra state i Azure Storage Container
3. Hantera Terraform plan/apply för main infrastructure

**Workflow kommer att köra terraform init med:**
```bash
terraform init \
  -backend-config="resource_group_name=rg-clo-k8s-inl01-tfstate" \
  -backend-config="storage_account_name=stclok8sinl01tfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=dev/terraform.tfstate"
```