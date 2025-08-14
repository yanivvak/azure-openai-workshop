// Azure AI Foundry Infrastructure - Bicep Template
// This template creates Azure Resource Group and AI Foundry resources

targetScope = 'subscription'

// Parameters
@description('Name of the resource group')
param resourceGroupName string = ''

@description('Location for all resources')
param location string = 'Sweden Central'

@description('Environment name (dev, test, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'

@description('Name of the AI Foundry resource')
param aiFoundryName string = ''

@description('Name of the AI Foundry project resource')
param projectName string = ''

@description('Display name for the AI Foundry project')
param projectDisplayName string = ''

@description('SKU for the AI Foundry resource')
@allowed(['S0', 'F0'])
param skuName string = 'S0'

@description('Disable local authentication (recommended for production)')
param disableLocalAuth bool = true

@description('Enable public network access')
param publicNetworkAccessEnabled bool = true

@description('Deploy a GPT-4.1 model deployment')
param deployModel bool = true

@description('Capacity for the model deployment (in thousands of TPM). Default 100 = 100K TPM for GPT-4.1 mini')
@minValue(1)
@maxValue(1000)
param modelCapacity int = 100

@description('Additional tags to apply to resources')
param additionalTags object = {}

// Generate a unique string for naming
var uniqueSuffix = uniqueString(subscription().subscriptionId)

// Construct names with defaults
var finalResourceGroupName = !empty(resourceGroupName) ? resourceGroupName : 'rg-foundry-${uniqueSuffix}'
var finalAiFoundryName = !empty(aiFoundryName) ? aiFoundryName : 'foundry-${uniqueSuffix}'
var finalProjectName = !empty(projectName) ? projectName : '${finalAiFoundryName}-project'
var finalProjectDisplayName = !empty(projectDisplayName) ? projectDisplayName : 'AI Foundry Project'

// Merge base tags with additional tags
var baseTags = {
  Environment: environment
  Project: 'Azure Foundry'
  CreatedBy: 'Bicep'
}
var allTags = union(baseTags, additionalTags)

// Create Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: finalResourceGroupName
  location: location
  tags: allTags
}

// Deploy AI Foundry resources to the resource group
module foundryResources 'modules/foundry.bicep' = {
  name: 'foundryDeployment'
  scope: resourceGroup
  params: {
    aiFoundryName: finalAiFoundryName
    aiProjectName: finalProjectName
    projectDisplayName: finalProjectDisplayName
    location: location
    skuName: skuName
    disableLocalAuth: disableLocalAuth
    publicNetworkAccessEnabled: publicNetworkAccessEnabled
    deployModel: deployModel
    modelCapacity: modelCapacity
    environment: environment
    additionalTags: additionalTags
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
output resourceGroupLocation string = resourceGroup.location
output aiFoundryName string = foundryResources.outputs.aiFoundryName
output aiFoundryId string = foundryResources.outputs.aiFoundryId
output aiFoundryEndpoint string = foundryResources.outputs.aiFoundryEndpoint
output aiFoundryProjectName string = foundryResources.outputs.aiProjectName
output aiFoundryProjectId string = foundryResources.outputs.aiProjectId
output aiFoundryProjectEndpoint string = foundryResources.outputs.aiProjectEndpoint
output modelDeploymentName string = foundryResources.outputs.modelDeploymentName
output modelDeploymentId string = foundryResources.outputs.modelDeploymentId
output subscriptionId string = foundryResources.outputs.subscriptionId
output location string = location

// Application Insights outputs
output applicationInsightsName string = foundryResources.outputs.applicationInsightsName
output applicationInsightsId string = foundryResources.outputs.applicationInsightsId
output applicationInsightsInstrumentationKey string = foundryResources.outputs.applicationInsightsInstrumentationKey
output applicationInsightsConnectionString string = foundryResources.outputs.applicationInsightsConnectionString
output logAnalyticsWorkspaceName string = foundryResources.outputs.logAnalyticsWorkspaceName
output logAnalyticsWorkspaceId string = foundryResources.outputs.logAnalyticsWorkspaceId

// Project Connection String
output projectConnectionString string = foundryResources.outputs.projectConnectionString

// Connection Information (matches Terraform connection_info output)
@secure()
output connectionInfo object = foundryResources.outputs.connectionInfo

// Portal URLs (matches Terraform portal_urls output)
output portalUrls object = foundryResources.outputs.portalUrls

// Workshop config (matches Terraform workshop_config output)
@secure()
output workshopConfig object = foundryResources.outputs.workshopConfig

// Environment variables output in .env format (matches Terraform env_variables output)
@secure()
output envVariables string = foundryResources.outputs.envVariables

// Individual environment variables for easy access in deploy script
output azureOpenAIEndpoint string = foundryResources.outputs.aiFoundryEndpoint
output azureOpenAIDeploymentName string = foundryResources.outputs.modelDeploymentName != '' ? foundryResources.outputs.modelDeploymentName : 'gpt-4.1-mini'
output azureOpenAIApiVersion string = '2024-10-21'
