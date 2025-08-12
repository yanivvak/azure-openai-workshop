# Deploy Azure AI Foundry with Terraform

This directory contains Terraform configuration files to deploy Azure AI Foundry resources.

## Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `terraform.tfvars.example` - Example variables file
- `deploy.sh` - Deployment script for bash/zsh
- `deploy.ps1` - Deployment script for PowerShell

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed (>= 1.0)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- Appropriate Azure permissions to create resource groups and AI services

## Quick Deploy

### Using the deployment script (bash/zsh)

```bash
# Make the script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### Manual Deployment

1. **Configure variables (optional)**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Configuration Options

### Required Variables
All variables have sensible defaults and are optional.

### Key Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `location` | string | `"East US 2"` | Azure region |
| `environment` | string | `"dev"` | Environment (dev/test/staging/prod) |
| `ai_foundry_name` | string | `""` (auto-generated) | AI Foundry resource name |
| `sku_name` | string | `"S0"` | SKU (F0 for free, S0 for standard) |
| `deploy_model` | bool | `true` | Deploy GPT-4.1-mini model |
| `disable_local_auth` | bool | `true` | Disable local auth (recommended) |

### Example deployment with custom values

```bash
terraform apply \
  -var="location=West US 2" \
  -var="environment=prod" \
  -var="ai_foundry_name=my-foundry" \
  -var="deploy_model=true"
```

## Outputs

After deployment, Terraform will output:

- Resource group information
- AI Foundry endpoint and connection details
- Model deployment information (if deployed)
- Portal URLs for easy access

To view outputs after deployment:
```bash
terraform output
```

To view sensitive outputs (like access keys):
```bash
terraform output ai_foundry_primary_access_key
```

## State Management

For production deployments, configure remote state storage:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "terraformstatestore"
    container_name       = "tfstate"
    key                  = "foundry.terraform.tfstate"
  }
}
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Authentication errors**: Ensure you're logged into Azure CLI
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

2. **Resource naming conflicts**: AI Foundry names must be globally unique
   - Use custom names or let Terraform generate unique names

3. **Quota limits**: Ensure your subscription has quota for AI services in the selected region

4. **Provider version conflicts**: Run `terraform init -upgrade` to update providers

### Useful Commands

```bash
# Check current Azure context
az account show

# List available locations
az account list-locations --output table

# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt

# Show current state
terraform show
```

## Security Considerations

- The template disables local authentication by default (recommended)
- Access keys are marked as sensitive in outputs
- Consider using managed identities for production workloads
- Review network access settings based on your security requirements

## Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure AI Services Documentation](https://learn.microsoft.com/azure/ai-services/)
