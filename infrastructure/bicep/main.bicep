// Azure AI Foundry Infrastructure - Bicep Template
// This template creates Azure Resource Group and AI Foundry resources

targetScope = 'subscription'

// Parameters
@description('Name of the resource group')
param resourceGroupName string = 'rg-foundry-${uniqueString(subscription().subscriptionId)}'

@description('Location for all resources')
param location string = 'eastus2'

@description('Name of the AI Foundry resource')
param aiFoundryName string = 'foundry-${uniqueString(resourceGroupName)}'

@description('Name of the AI Foundry project')
param aiProjectName string = '${aiFoundryName}-project'

@description('SKU for the AI Foundry resource')
@allowed(['S0', 'F0'])
param sku string = 'S0'

@description('Enable local authentication (set to false for production)')
param disableLocalAuth bool = false

@description('Deploy a GPT-4o model deployment')
param deployModel bool = true

// Create Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
  tags: {
    environment: 'development'
    project: 'azure-foundry'
    createdBy: 'bicep'
  }
}

// Deploy AI Foundry resources to the resource group
module foundryResources 'modules/foundry.bicep' = {
  name: 'foundryDeployment'
  scope: resourceGroup
  params: {
    aiFoundryName: aiFoundryName
    aiProjectName: aiProjectName
    location: location
    sku: sku
    disableLocalAuth: disableLocalAuth
    deployModel: deployModel
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
output aiFoundryName string = foundryResources.outputs.aiFoundryName
output aiFoundryEndpoint string = foundryResources.outputs.aiFoundryEndpoint
output aiProjectName string = foundryResources.outputs.aiProjectName
output aiProjectEndpoint string = foundryResources.outputs.aiProjectEndpoint
output modelDeploymentName string = foundryResources.outputs.modelDeploymentName
output subscriptionId string = foundryResources.outputs.subscriptionId
output location string = location

// Application Insights outputs
output applicationInsightsName string = foundryResources.outputs.applicationInsightsName
output applicationInsightsConnectionString string = foundryResources.outputs.applicationInsightsConnectionString
output logAnalyticsWorkspaceName string = foundryResources.outputs.logAnalyticsWorkspaceName

// Project Connection String
output projectConnectionString string = foundryResources.outputs.projectConnectionString
