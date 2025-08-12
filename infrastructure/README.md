# Azure AI Foundry Infrastructure as Code

This directory contains Infrastructure as Code (IaC) templates for deploying Azure AI Foundry resources using both **Bicep** and **Terraform**.

## 🚀 Quick Start

Choose your preferred tool:

### Option 1: Bicep (Azure-native)
```bash
cd bicep
./deploy.sh
```

### Option 2: Terraform (Multi-cloud)
```bash
cd terraform
./deploy.sh
```

## 📁 Directory Structure

```
infrastructure/
├── bicep/                    # Azure Bicep templates
│   ├── main.bicep           # Main deployment template
│   ├── modules/
│   │   └── foundry.bicep    # Foundry resources module
│   ├── deploy.sh            # Deployment script
│   └── README.md            # Bicep-specific documentation
├── terraform/               # Terraform configuration
│   ├── main.tf              # Main Terraform configuration
│   ├── variables.tf         # Variable definitions
│   ├── outputs.tf           # Output definitions
│   ├── terraform.tfvars.example  # Example variables
│   ├── deploy.sh            # Deployment script
│   └── README.md            # Terraform-specific documentation
└── README.md               # This file
```

## 🏗️ What Gets Deployed

Both templates deploy the following Azure resources:

### Core Resources
- **Resource Group** - Container for all resources
- **Azure AI Foundry Account** - Main AI services resource (Cognitive Services with AIServices kind)
- **AI Foundry Project** - Development workspace for AI applications

### Optional Resources
- **GPT-4.1-mini Model Deployment** - Ready-to-use language model (enabled by default)

## 🔧 Prerequisites

### Common Requirements
- Azure CLI installed and authenticated
- Active Azure subscription with appropriate permissions
- Subscription must have quota for AI services

### Bicep-specific
- Bicep CLI (installed with Azure CLI)

### Terraform-specific  
- Terraform >= 1.0
- AzureRM provider

## ⚙️ Configuration Options

### Key Parameters

| Parameter | Description | Default | Notes |
|-----------|-------------|---------|-------|
| Location | Azure region | East US 2 | Choose region with AI services availability |
| Environment | Deployment environment | dev | dev/test/staging/prod |
| SKU | Service tier | S0 | F0 (free) or S0 (standard) |
| Deploy Model | Include GPT-4.1-mini deployment | true | Requires standard SKU |
| Disable Local Auth | Enhanced security | true | Recommended for production |

## 🎯 Choosing Between Bicep and Terraform

### Use **Bicep** if:
- ✅ Azure-only deployment
- ✅ Want native Azure integration
- ✅ Prefer Azure-first tooling
- ✅ Team is Azure-focused
- ✅ Want automatic portal integration

### Use **Terraform** if:
- ✅ Multi-cloud strategy
- ✅ Existing Terraform workflows
- ✅ Need advanced state management
- ✅ Want provider ecosystem
- ✅ Team uses HashiCorp tools

## 📋 Deployment Steps

### 1. Choose Your Tool
```bash
# For Bicep
cd bicep

# For Terraform  
cd terraform
```

### 2. Review Configuration
Both tools provide example configurations and sensible defaults.

### 3. Deploy
```bash
# Both tools have deployment scripts
./deploy.sh
```

### 4. Access Your Resources
- **Azure AI Foundry Portal**: https://ai.azure.com
- **Azure Portal**: Check outputs for direct links

## 🔍 Post-Deployment

### Verify Deployment
1. Check the Azure portal for created resources
2. Visit Azure AI Foundry portal
3. Test API endpoints (if keys are enabled)

### Get Connection Information
```bash
# Bicep - check deployment outputs
az deployment sub show --name <deployment-name> --query properties.outputs

# Terraform - show outputs
terraform output
```

## 🧹 Cleanup

### Remove All Resources
```bash
# Bicep
az group delete --name <resource-group-name> --yes --no-wait

# Terraform
terraform destroy
```

## 🔐 Security Best Practices

1. **Disable Local Authentication** - Use managed identities or Azure AD
2. **Network Security** - Configure private endpoints for production
3. **Access Control** - Use Azure RBAC for fine-grained permissions
4. **Key Management** - Rotate keys regularly if using key-based auth
5. **Monitoring** - Enable Azure Monitor and diagnostic logs

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Authentication errors | Run `az login` and verify subscription |
| Naming conflicts | AI Foundry names must be globally unique |
| Quota exceeded | Request quota increase or change region |
| Permission denied | Verify Contributor role on subscription |
| Model deployment fails | Ensure S0 SKU and region supports models |

### Debug Commands
```bash
# Check Azure context
az account show

# List available regions
az account list-locations --output table

# Check AI services availability
az provider show --namespace Microsoft.CognitiveServices
```

## 📚 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure AI Services](https://learn.microsoft.com/azure/ai-services/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
