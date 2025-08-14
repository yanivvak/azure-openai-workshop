# Azure AI Foundry - Bicep Deployment

This directory contains Bicep templates for deploying Azure AI Foundry resources, updated to match the functionality of the working Terraform configuration.

## Features

- **Azure AI Foundry Account** (AIServices) with configurable settings
- **AI Foundry Project** with custom display name
- **GPT-4.1-mini Model Deployment** (optional, with configurable capacity)
- **Application Insights** for observability and tracing
- **Log Analytics Workspace** for centralized logging
- **Comprehensive outputs** matching Terraform functionality
- **Flexible parameter configuration** with validation
- **Environment-based tagging** and additional custom tags

## Architecture

```
Azure Subscription
└── Resource Group
    ├── AI Foundry Account (Cognitive Services - AIServices)
    │   ├── AI Foundry Project
    │   └── Model Deployment (GPT-4.1-mini) [Optional]
    ├── Application Insights (for tracing)
    └── Log Analytics Workspace
```

## Files

- `main.bicep` - Main template that creates resource group and deploys Foundry resources
- `modules/foundry.bicep` - Module containing the AI Foundry resource definitions
- `parameters.bicepparam` - Example parameters file matching Terraform variables
- `deploy.sh` - Enhanced deployment script with full parameter support
- `README.md` - This documentation

## Parameters

### Core Configuration
- `resourceGroupName`: Resource group name (auto-generated if empty)
- `location`: Azure region (default: "Sweden Central")
- `environment`: Environment type (dev/test/staging/prod, default: "dev")

### AI Foundry Configuration
- `aiFoundryName`: AI Foundry resource name (auto-generated if empty)
- `projectName`: Project resource name (auto-generated if empty)
- `projectDisplayName`: Display name for the project (auto-generated if empty)
- `skuName`: SKU tier (S0/F0, default: "S0")

### Security & Access
- `disableLocalAuth`: Disable API key authentication (default: true)
- `publicNetworkAccessEnabled`: Enable public network access (default: true)

### Model Deployment
- `deployModel`: Deploy GPT-4.1-mini model (default: true)
- `modelCapacity`: Model capacity in thousands of TPM, 1-1000 (default: 100)

### Tagging
- `additionalTags`: Custom tags object (default: {})

## Quick Start

### Prerequisites

1. **Azure CLI**: Install and configure
   ```bash
   # Install Azure CLI (if not already installed)
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # Login to Azure
   az login
   ```

2. **Permissions**: Ensure you have Contributor access to the target subscription

### Option 1: Interactive Deployment (Recommended)

```bash
# Navigate to the bicep directory
cd infrastructure/bicep

# Make deploy script executable
chmod +x deploy.sh

# Run the interactive deployment script
./deploy.sh
```

The script will prompt you for:
- Location (default: Sweden Central)
- Environment (dev/test/staging/prod)
- Resource group prefix
- AI Foundry name prefix
- SKU selection
- Model deployment options
- Security settings

### Option 2: Direct Deployment

```bash
# Deploy with default parameters
az deployment sub create \
  --name "foundry-deployment-$(date +%s)" \
  --location "Sweden Central" \
  --template-file main.bicep

# Deploy with custom parameters
az deployment sub create \
  --name "foundry-deployment-$(date +%s)" \
  --location "Sweden Central" \
  --template-file main.bicep \
  --parameters \
    resourceGroupName="rg-my-foundry" \
    aiFoundryName="my-foundry" \
    environment="dev" \
    skuName="S0" \
    deployModel=true \
    modelCapacity=100
```

### Option 3: Using Parameters File

1. Copy and customize the parameters file:
   ```bash
   cp parameters.bicepparam my-parameters.bicepparam
   # Edit my-parameters.bicepparam with your values
   ```

2. Deploy with parameters file:
   ```bash
   az deployment sub create \
     --name "foundry-deployment-$(date +%s)" \
     --location "Sweden Central" \
     --template-file main.bicep \
     --parameters my-parameters.bicepparam
   ```

## Outputs

The deployment provides comprehensive outputs matching the Terraform configuration:

### Basic Outputs
- `resourceGroupName`, `resourceGroupId`, `resourceGroupLocation`
- `aiFoundryName`, `aiFoundryId`, `aiFoundryEndpoint`
- `aiFoundryProjectName`, `aiFoundryProjectId`, `aiFoundryProjectEndpoint`
- `modelDeploymentName`, `modelDeploymentId`
- `subscriptionId`, `location`

### Observability Outputs
- `applicationInsightsName`, `applicationInsightsId`
- `applicationInsightsConnectionString`, `logAnalyticsWorkspaceName`

### Connection Information
- `projectConnectionString`: For Azure AI Foundry SDK
- `connectionInfo`: Complete connection details object
- `portalUrls`: Useful Azure portal links
- `workshopConfig`: Key configuration for workshops
- `envVariables`: Environment variables in .env format

## Post-Deployment

### Verify Deployment

```bash
# List created resources
az resource list --resource-group <your-resource-group-name> --output table

# Get deployment outputs
az deployment sub show --name <deployment-name> --query properties.outputs
```

### Access Your AI Foundry

1. **Azure AI Foundry Portal**: https://ai.azure.com
2. **Azure Portal**: Use the `portalUrls.resource_group_portal` output
3. **Direct Resource**: Use the `portalUrls.ai_foundry_resource_portal` output

### Configure Environment Variables

The deployment outputs environment variables in .env format. You can save them to a file:

```bash
# Get environment variables from deployment output
az deployment sub show --name <deployment-name> \
  --query properties.outputs.envVariables.value \
  --output tsv > .env
```

## Configuration Examples

### Development Environment
```bicep
param environment = 'dev'
param skuName = 'F0'  // Free tier
param deployModel = true
param modelCapacity = 1  // Minimal capacity
param disableLocalAuth = false  // Allow API keys for development
```

### Production Environment
```bicep
param environment = 'prod'
param skuName = 'S0'  // Standard tier
param deployModel = true
param modelCapacity = 100  // Higher capacity
param disableLocalAuth = true  // Enhanced security
param publicNetworkAccessEnabled = false  // Private access only
```

## Comparison with Terraform

This Bicep configuration provides equivalent functionality to the Terraform version with these key features:

✅ **Identical Resource Structure**: Same resources and configurations
✅ **Matching Parameters**: All Terraform variables have Bicep equivalents  
✅ **Complete Outputs**: All Terraform outputs are available in Bicep
✅ **Security Settings**: Same authentication and network access options
✅ **Model Deployment**: Same GPT-4.1-mini deployment with capacity control
✅ **Observability**: Identical Application Insights and Log Analytics setup
✅ **Tagging Strategy**: Same environment and custom tagging approach

## Troubleshooting

### Common Issues

1. **Deployment Fails with Permissions Error**
   ```bash
   # Ensure you have the correct role
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

2. **Resource Name Conflicts**
   - Use unique prefixes or let the template auto-generate names
   - Check existing resources: `az resource list --output table`

3. **Quota Limitations**
   ```bash
   # Check cognitive services quota
   az cognitiveservices account list-usage \
     --resource-group <resource-group> \
     --name <ai-foundry-name>
   ```

### Validation

```bash
# Validate template before deployment
az deployment sub validate \
  --location "Sweden Central" \
  --template-file main.bicep \
  --parameters parameters.bicepparam
```

## Cleanup

### Delete All Resources
```bash
# Delete the entire resource group (removes all resources)
az group delete --name <resource-group-name> --yes --no-wait
```

### Delete Specific Resources
```bash
# Delete only the AI Foundry resources
az cognitiveservices account delete \
  --resource-group <resource-group-name> \
  --name <ai-foundry-name>
```

## Next Steps

1. **Access AI Foundry**: Visit https://ai.azure.com
2. **Run Workshop Notebooks**: Use the connection information in your notebooks
3. **Configure Tracing**: Use the Application Insights connection string
4. **Deploy Models**: Add additional model deployments as needed

For more information about Azure AI Foundry, visit the [official documentation](https://docs.microsoft.com/azure/ai-services/openai/).
