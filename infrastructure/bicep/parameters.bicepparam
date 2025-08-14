// Bicep parameters file - corresponds to terraform.tfvars
using 'main.bicep'

// Resource Group Configuration
// param resourceGroupName = 'rg-foundry-myproject'
param location = 'Sweden Central'
param environment = 'dev'

// AI Foundry Configuration
// param aiFoundryName = 'foundry-myproject'
// param projectName = 'foundry-myproject-proj'
// param projectDisplayName = 'My AI Foundry Project'
param skuName = 'S0'

// Security Configuration
param disableLocalAuth = true
param publicNetworkAccessEnabled = true

// Model Deployment
param deployModel = true
param modelCapacity = 100  // 100K TPM for better evaluation performance

// Additional Tags
param additionalTags = {
  CostCenter: 'Engineering'
  Owner: 'DataScience Team'
  Purpose: 'AI Development'
}
