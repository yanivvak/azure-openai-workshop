# Deploy Azure AI Foundry with Bicep

This directory contains Bicep templates to deploy Azure AI Foundry resources.

## Files

- `main.bicep` - Main template that creates a resource group and deploys Foundry resources
- `modules/foundry.bicep` - Module containing the AI Foundry resource definitions
- `deploy.sh` - Deployment script for bash/zsh
- `deploy.ps1` - Deployment script for PowerShell

## Prerequisites

- Azure CLI installed and logged in
- Bicep CLI installed
- Appropriate Azure permissions to create resource groups and AI services

## Quick Deploy

### Using Azure CLI (bash/zsh)

```bash
# Make the script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### Using PowerShell

```powershell
# Run deployment
./deploy.ps1
```

### Manual Deployment

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP_NAME="rg-foundry-$(date +%s)"
LOCATION="eastus2"
AI_FOUNDRY_NAME="foundry-$(date +%s)"

# Set subscription
az account set --subscription $SUBSCRIPTION_ID

# Deploy to subscription scope
az deployment sub create \
  --name "foundry-deployment-$(date +%s)" \
  --location $LOCATION \
  --template-file main.bicep \
  --parameters \
    resourceGroupName=$RESOURCE_GROUP_NAME \
    location=$LOCATION \
    aiFoundryName=$AI_FOUNDRY_NAME \
    deployModel=true
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `resourceGroupName` | string | `rg-foundry-{uniqueString}` | Name of the resource group |
| `location` | string | `eastus2` | Azure region for deployment |
| `aiFoundryName` | string | `foundry-{uniqueString}` | Name of the AI Foundry resource |
| `aiProjectName` | string | `{aiFoundryName}-project` | Name of the AI Foundry project |
| `sku` | string | `S0` | SKU for AI Foundry (S0 or F0) |
| `disableLocalAuth` | bool | `true` | Disable local authentication |
| `deployModel` | bool | `true` | Deploy GPT-4.1-mini model |

## Outputs

- `resourceGroupName` - Name of the created resource group
- `aiFoundryName` - Name of the AI Foundry resource
- `aiFoundryEndpoint` - Endpoint URL for the AI Foundry
- `aiProjectName` - Name of the AI Foundry project

## Clean Up

```bash
# Delete the resource group and all resources
az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait
```
