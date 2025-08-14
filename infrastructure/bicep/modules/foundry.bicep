// Azure AI Foundry Resources Module
// This module creates the AI Foundry account and project

@description('Name of the AI Foundry resource')
param aiFoundryName string

@description('Name of the AI Foundry project')
param aiProjectName string

@description('Display name for the AI Foundry project')
param projectDisplayName string

@description('Location for all resources')
param location string

@description('SKU for the AI Foundry resource')
param skuName string

@description('Disable local authentication')
param disableLocalAuth bool

@description('Enable public network access')
param publicNetworkAccessEnabled bool

@description('Deploy a model')
param deployModel bool

@description('Capacity for the model deployment (in thousands of TPM)')
param modelCapacity int

@description('Environment name')
param environment string

@description('Additional tags to apply to resources')
param additionalTags object

// Merge base tags with additional tags
var baseTags = {
  Environment: environment
  Project: 'Azure Foundry'
  CreatedBy: 'Bicep'
}
var allTags = union(baseTags, additionalTags)

// AI Foundry Account (Cognitive Services Account with AIServices kind)
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: aiFoundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: skuName
  }
  kind: 'AIServices'
  properties: {
    // Support both Entra ID and API Key authentication
    disableLocalAuth: disableLocalAuth
    
    // Specifies that this is an AI Foundry resource
    allowProjectManagement: true
    
    // Set custom subdomain name for DNS names created for this Foundry resource
    customSubDomainName: aiFoundryName
    
    // Set public network access
    publicNetworkAccess: publicNetworkAccessEnabled ? 'Enabled' : 'Disabled'
  }
  tags: allTags
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
    displayName: projectDisplayName
    description: 'Azure AI Foundry project for workshop'
  }
  tags: allTags
}

// Optional: Deploy GPT-4.1-mini model
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = if (deployModel) {
  parent: aiFoundry
  name: 'gpt-4.1-mini'
  sku: {
    capacity: modelCapacity
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1-mini'
      version: '2025-04-14'
    }
    raiPolicyName: 'Microsoft.Default'
  }
}

// Log Analytics Workspace for Application Insights
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${aiFoundryName}-workspace'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: union(allTags, {
    Purpose: 'AI Foundry Logging'
  })
}

// Application Insights for observability and tracing
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${aiFoundryName}-insights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: union(allTags, {
    Purpose: 'AI Foundry Observability'
  })
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

// Application Insights outputs
output applicationInsightsName string = applicationInsights.name
output applicationInsightsId string = applicationInsights.id
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

// Project Connection String - format for Azure AI Foundry SDK
output projectConnectionString string = 'SubscriptionId=${subscription().subscriptionId};ResourceGroupName=${resourceGroup().name};ProjectName=${aiProjectName}'

// Additional outputs to match Terraform
output modelDeploymentId string = deployModel ? modelDeployment.id : ''
output resourceGroupId string = resourceGroup().id
output resourceGroupLocation string = resourceGroup().location

// Connection Information (matches Terraform connection_info output)
@secure()
output connectionInfo object = {
  endpoint: aiFoundry.properties.endpoint
  resource_name: aiFoundry.name
  resource_group: resourceGroup().name
  subscription_id: subscription().subscriptionId
  location: location
  model_deployed: deployModel
  model_name: deployModel ? 'gpt-4.1' : 'none'
  project_endpoint: 'https://${aiFoundryName}.services.ai.azure.com/api/projects/${aiProjectName}'
  project_name: aiProject.name
  project_connection_string: 'SubscriptionId=${subscription().subscriptionId};ResourceGroupName=${resourceGroup().name};ProjectName=${aiProjectName}'
  application_insights_name: applicationInsights.name
  application_insights_connection_string: applicationInsights.properties.ConnectionString
}

// Portal URLs (matches Terraform portal_urls output)
output portalUrls object = {
  ai_foundry_portal: 'https://ai.azure.com'
  resource_group_portal: 'https://portal.azure.com/#@/resource/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/overview'
  ai_foundry_resource_portal: 'https://portal.azure.com/#@/resource${aiFoundry.id}/overview'
}

// Workshop config (matches Terraform workshop_config output)
@secure()
output workshopConfig object = {
  endpoint: aiFoundry.properties.endpoint
  project_endpoint: 'https://${aiFoundryName}.services.ai.azure.com/api/projects/${aiProjectName}'
  project_connection_string: 'SubscriptionId=${subscription().subscriptionId};ResourceGroupName=${resourceGroup().name};ProjectName=${aiProjectName}'
  model_deployment_name: deployModel ? 'gpt-4.1' : 'none'
  app_insights_connection_string: applicationInsights.properties.ConnectionString
}

// Environment variables output in .env format (matches Terraform env_variables output)
@secure()
output envVariables string = '''
AZURE_OPENAI_ENDPOINT=${aiFoundry.properties.endpoint}
AZURE_OPENAI_DEPLOYMENT_NAME=${deployModel ? 'gpt-4.1-mini' : 'gpt-4.1-mini'}
AZURE_OPENAI_API_VERSION=2024-10-21

PROJECT_CONNECTION_STRING=SubscriptionId=${subscription().subscriptionId};ResourceGroupName=${resourceGroup().name};ProjectName=${aiProjectName}
APPLICATION_INSIGHTS_CONNECTION_STRING=${applicationInsights.properties.ConnectionString}
PROJECT_ENDPOINT=https://${aiFoundryName}.services.ai.azure.com/api/projects/${aiProjectName}
'''
