// General params
param location string = resourceGroup().location

// OpenAI params
param OpenAIServiceName string = 'openai-${uniqueString(resourceGroup().id)}'
param openai_deployments array = [
  {
    name: 'text-embedding-ada-002'
	  model_name: 'text-embedding-ada-002'
    version: '2'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 20
    sku_name: 'Standard'
  }
  {
    name: 'gpt-4'
	  model_name: 'gpt-4'
    version: '1106-Preview'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 20
    sku_name: 'Standard'
  }
  {
    name: 'gpt-4'
	  model_name: 'gpt-v'
    version: 'vision-preview'
    raiPolicyName: 'Microsoft.Default'
    sku_capacity: 20
    sku_name: 'Standard'
  }
  
]

// AI Search params
param aisearch_name string = 'aisearch-${uniqueString(resourceGroup().id)}'

resource openai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: OpenAIServiceName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

@batchSize(1)
resource model 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in openai_deployments: {
  name: deployment.model_name
  parent: openai
  sku: {
	name: deployment.sku_name
	capacity: deployment.sku_capacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.name
      version: deployment.version
    }
    raiPolicyName: deployment.raiPolicyName
  }
}]

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aisearch_name
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
  }
}
