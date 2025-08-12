# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.foundry_rg.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.foundry_rg.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.foundry_rg.location
}

# AI Foundry Outputs
output "ai_foundry_name" {
  description = "Name of the AI Foundry resource"
  value       = azapi_resource.ai_foundry.name
}

output "ai_foundry_id" {
  description = "ID of the AI Foundry resource"
  value       = azapi_resource.ai_foundry.id
}

output "ai_foundry_endpoint" {
  description = "Endpoint URL for the AI Foundry"
  value       = azapi_resource.ai_foundry.output.properties.endpoint
}

# Note: For AzAPI resources, access keys should be retrieved using azapi_resource_action
# data source or Azure CLI when needed

# AI Foundry Project Outputs
output "ai_foundry_project_name" {
  description = "Name of the AI Foundry project"
  value       = azapi_resource.ai_foundry_project.name
}

output "ai_foundry_project_id" {
  description = "ID of the AI Foundry project"
  value       = azapi_resource.ai_foundry_project.id
}

output "ai_foundry_project_endpoint" {
  description = "Endpoint URL for the AI Foundry project"
  value       = "https://${azapi_resource.ai_foundry.name}.services.ai.azure.com/api/projects/${azapi_resource.ai_foundry_project.name}"
}

# Model Deployment Outputs
output "model_deployment_name" {
  description = "Name of the deployed model"
  value       = var.deploy_model ? azurerm_cognitive_deployment.gpt41_deployment[0].name : "No model deployed"
}

output "model_deployment_id" {
  description = "ID of the deployed model"
  value       = var.deploy_model ? azurerm_cognitive_deployment.gpt41_deployment[0].id : "No model deployed"
}

# Application Insights Outputs
output "application_insights_name" {
  description = "Name of the Application Insights resource"
  value       = azurerm_application_insights.foundry_insights.name
}

output "application_insights_id" {
  description = "ID of the Application Insights resource"
  value       = azurerm_application_insights.foundry_insights.id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.foundry_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string for tracing"
  value       = azurerm_application_insights.foundry_insights.connection_string
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.foundry_workspace.name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.foundry_workspace.id
}

# Connection Information
output "connection_info" {
  description = "Connection information for accessing the AI Foundry"
  sensitive   = true
  value = {
    endpoint           = azapi_resource.ai_foundry.output.properties.endpoint
    resource_name      = azapi_resource.ai_foundry.name
    resource_group     = azurerm_resource_group.foundry_rg.name
    subscription_id    = data.azurerm_client_config.current.subscription_id
    location          = azurerm_resource_group.foundry_rg.location
    model_deployed    = var.deploy_model
    model_name        = var.deploy_model ? "gpt-4.1" : "none"
    project_endpoint  = "https://${azapi_resource.ai_foundry.name}.services.ai.azure.com/api/projects/${azapi_resource.ai_foundry_project.name}"
    project_name      = azapi_resource.ai_foundry_project.name
    project_connection_string = "SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azapi_resource.ai_foundry_project.name}"
    application_insights_name = azurerm_application_insights.foundry_insights.name
    application_insights_connection_string = azurerm_application_insights.foundry_insights.connection_string
  }
}

# Portal URLs
output "portal_urls" {
  description = "Useful portal URLs"
  value = {
    ai_foundry_portal = "https://ai.azure.com"
    resource_group_portal = "https://portal.azure.com/#@/resource/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.foundry_rg.name}/overview"
    ai_foundry_resource_portal = "https://portal.azure.com/#@/resource${azapi_resource.ai_foundry.id}/overview"
  }
}

# Project Connection String
output "project_connection_string" {
  description = "Project connection string for Azure AI Foundry SDK"
  value = "SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azapi_resource.ai_foundry_project.name}"
}

# Summary of key configuration values for the workshop
output "workshop_config" {
  description = "Key configuration values needed for the workshop"
  value = {
    endpoint                    = azapi_resource.ai_foundry.output.properties.endpoint
    project_endpoint            = "https://${azapi_resource.ai_foundry.name}.services.ai.azure.com/api/projects/${azapi_resource.ai_foundry_project.name}"
    project_connection_string   = "SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azapi_resource.ai_foundry_project.name}"
    model_deployment_name       = var.deploy_model ? "gpt-4.1" : "none"
    app_insights_connection_string = azurerm_application_insights.foundry_insights.connection_string
  }
  sensitive = true
}

# Environment variables output in .env format
output "env_variables" {
  description = "Environment variables formatted for .env file"
  value = <<-EOT
AZURE_OPENAI_ENDPOINT=${azapi_resource.ai_foundry.output.properties.endpoint}
AZURE_OPENAI_DEPLOYMENT_NAME=${var.deploy_model ? "gpt-4.1-mini" : "gpt-4.1-mini"}
AZURE_OPENAI_API_VERSION=2024-10-21

PROJECT_CONNECTION_STRING=SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azapi_resource.ai_foundry_project.name}
APPLICATION_INSIGHTS_CONNECTION_STRING=${azurerm_application_insights.foundry_insights.connection_string}
PROJECT_ENDPOINT=https://${azapi_resource.ai_foundry.name}.services.ai.azure.com/api/projects/${azapi_resource.ai_foundry_project.name}
EOT
  sensitive = true
}
