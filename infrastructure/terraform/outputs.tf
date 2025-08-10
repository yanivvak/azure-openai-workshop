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
  value       = azurerm_cognitive_account.ai_foundry.name
}

output "ai_foundry_id" {
  description = "ID of the AI Foundry resource"
  value       = azurerm_cognitive_account.ai_foundry.id
}

output "ai_foundry_endpoint" {
  description = "Endpoint URL for the AI Foundry"
  value       = azurerm_cognitive_account.ai_foundry.endpoint
}

output "ai_foundry_primary_access_key" {
  description = "Primary access key for the AI Foundry (sensitive)"
  value       = azurerm_cognitive_account.ai_foundry.primary_access_key
  sensitive   = true
}

output "ai_foundry_secondary_access_key" {
  description = "Secondary access key for the AI Foundry (sensitive)"
  value       = azurerm_cognitive_account.ai_foundry.secondary_access_key
  sensitive   = true
}

# Model Deployment Outputs
output "model_deployment_name" {
  description = "Name of the deployed model"
  value       = var.deploy_model ? azurerm_cognitive_deployment.gpt4o_deployment[0].name : "No model deployed"
}

output "model_deployment_id" {
  description = "ID of the deployed model"
  value       = var.deploy_model ? azurerm_cognitive_deployment.gpt4o_deployment[0].id : "No model deployed"
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
  value = {
    endpoint           = azurerm_cognitive_account.ai_foundry.endpoint
    resource_name      = azurerm_cognitive_account.ai_foundry.name
    resource_group     = azurerm_resource_group.foundry_rg.name
    subscription_id    = data.azurerm_client_config.current.subscription_id
    location          = azurerm_resource_group.foundry_rg.location
    model_deployed    = var.deploy_model
    model_name        = var.deploy_model ? "gpt-4o" : "none"
    project_endpoint  = "https://${azurerm_cognitive_account.ai_foundry.name}.services.ai.azure.com/api/projects/${azurerm_cognitive_account.ai_foundry.name}-project"
    project_connection_string = "SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azurerm_cognitive_account.ai_foundry.name}-project"
    application_insights_name = azurerm_application_insights.foundry_insights.name
    application_insights_connection_string = azurerm_application_insights.foundry_insights.connection_string
  }
}

# Current Azure configuration
data "azurerm_client_config" "current" {}

# Portal URLs
output "portal_urls" {
  description = "Useful portal URLs"
  value = {
    ai_foundry_portal = "https://ai.azure.com"
    resource_group_portal = "https://portal.azure.com/#@/resource/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.foundry_rg.name}/overview"
    ai_foundry_resource_portal = "https://portal.azure.com/#@/resource${azurerm_cognitive_account.ai_foundry.id}/overview"
  }
}

# Project Connection String
output "project_connection_string" {
  description = "Project connection string for Azure AI Foundry SDK"
  value = "SubscriptionId=${data.azurerm_client_config.current.subscription_id};ResourceGroupName=${azurerm_resource_group.foundry_rg.name};ProjectName=${azurerm_cognitive_account.ai_foundry.name}-project"
}
