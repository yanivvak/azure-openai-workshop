// Azure AI Foundry Resources Module
// This module creates the AI Foundry account and project

@description('Name of the AI Foundry resource')
param aiFoundryName string

@description('Name of the AI Foundry project')
param aiProjectName string

@description('Location for all resources')
param location string

@description('SKU for the AI Foundry resource')
param sku string

@description('Disable local authentication')
param disableLocalAuth bool

@description('Deploy a model')
param deployModel bool

// AI Foundry Account (Cognitive Services Account with AIServices kind)
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  kind: 'AIServices'
  properties: {
    // Required to work in AI Foundry - allows project management
    allowProjectManagement: true
    
    // Defines developer API endpoint subdomain
    customSubDomainName: aiFoundryName
    
    // Disable local auth for better security (only if not needed for key access)
    disableLocalAuth: disableLocalAuth
    
    // Public network access
    publicNetworkAccess: 'Enabled'
  }
  tags: {
    purpose: 'AI Foundry'
    environment: 'development'
  }
}

// AI Foundry Project
resource aiProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: aiProjectName
  parent: aiFoundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // Project-level settings
  }
  tags: {
    purpose: 'AI Foundry Project'
    environment: 'development'
  }
}

// Optional: Deploy GPT-4o model
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = if (deployModel) {
  parent: aiFoundry
  name: 'gpt-4o'
  sku: {
    capacity: 1
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-05-13'
    }
  }
}

// Outputs
output aiFoundryName string = aiFoundry.name
output aiFoundryId string = aiFoundry.id
output aiFoundryEndpoint string = aiFoundry.properties.endpoint
// Only output key if local auth is enabled
@secure()
output aiFoundryKey string = disableLocalAuth ? '' : aiFoundry.listKeys().key1
output aiProjectName string = aiProject.name
output aiProjectId string = aiProject.id
output aiProjectEndpoint string = 'https://${aiFoundryName}.services.ai.azure.com/api/projects/${aiProjectName}'
output modelDeploymentName string = deployModel ? modelDeployment.name : ''
output resourceGroupName string = resourceGroup().name
output subscriptionId string = subscription().subscriptionId
output location string = location
