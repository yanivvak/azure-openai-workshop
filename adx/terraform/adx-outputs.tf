# Outputs for standalone Azure Data Explorer (ADX) deployment

# Resource Group Information
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.adx_rg.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.adx_rg.location
}

# ADX Cluster Information
output "adx_cluster_name" {
  description = "Name of the Azure Data Explorer cluster"
  value       = azurerm_kusto_cluster.adx_cluster.name
}

output "adx_cluster_uri" {
  description = "URI of the Azure Data Explorer cluster"
  value       = azurerm_kusto_cluster.adx_cluster.uri
}

output "adx_cluster_data_ingestion_uri" {
  description = "Data ingestion URI of the Azure Data Explorer cluster"
  value       = azurerm_kusto_cluster.adx_cluster.data_ingestion_uri
}

output "adx_database_name" {
  description = "Name of the ADX database"
  value       = azurerm_kusto_database.tracing_db.name
}

# Storage Account Information
output "adx_storage_account_name" {
  description = "Name of the storage account for ADX"
  value       = azurerm_storage_account.adx_storage.name
}

output "adx_storage_account_key" {
  description = "Primary access key for the ADX storage account"
  value       = azurerm_storage_account.adx_storage.primary_access_key
  sensitive   = true
}

output "adx_storage_connection_string" {
  description = "Connection string for the ADX storage account"
  value       = azurerm_storage_account.adx_storage.primary_connection_string
  sensitive   = true
}

output "adx_storage_container_name" {
  description = "Name of the storage container for trace data"
  value       = azurerm_storage_container.trace_data.name
}

# Event Hub Information
output "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  value       = azurerm_eventhub_namespace.tracing_namespace.name
}

output "eventhub_name" {
  description = "Name of the Event Hub for tracing"
  value       = azurerm_eventhub.tracing_hub.name
}

output "eventhub_connection_string" {
  description = "Connection string for the Event Hub"
  value       = azurerm_eventhub_namespace.tracing_namespace.default_primary_connection_string
  sensitive   = true
}

# Environment Variables for .env file
output "env_variables" {
  description = "Environment variables for ADX configuration"
  value = <<-EOT
# Azure Data Explorer Configuration
ADX_CLUSTER_URI=${azurerm_kusto_cluster.adx_cluster.uri}
ADX_DATABASE_NAME=${azurerm_kusto_database.tracing_db.name}
ADX_CLUSTER_NAME=${azurerm_kusto_cluster.adx_cluster.name}
ADX_DATA_INGESTION_URI=${azurerm_kusto_cluster.adx_cluster.data_ingestion_uri}

# Storage Configuration
ADX_STORAGE_ACCOUNT_NAME=${azurerm_storage_account.adx_storage.name}
ADX_STORAGE_CONTAINER_NAME=${azurerm_storage_container.trace_data.name}

# Event Hub Configuration
EVENTHUB_NAMESPACE=${azurerm_eventhub_namespace.tracing_namespace.name}
EVENTHUB_NAME=${azurerm_eventhub.tracing_hub.name}

# Resource Configuration
AZURE_RESOURCE_GROUP=${azurerm_resource_group.adx_rg.name}
AZURE_LOCATION=${azurerm_resource_group.adx_rg.location}
AZURE_SUBSCRIPTION_ID=${data.azurerm_client_config.current.subscription_id}
AZURE_TENANT_ID=${data.azurerm_client_config.current.tenant_id}
EOT
}

# Security Information
output "adx_security_info" {
  description = "Security-related information for ADX access"
  value = {
    cluster_principal_id = azurerm_kusto_cluster.adx_cluster.identity[0].principal_id
    resource_group_name  = azurerm_resource_group.adx_rg.name
    cluster_location     = azurerm_kusto_cluster.adx_cluster.location
  }
}

# Connection URLs
output "adx_web_ui_url" {
  description = "URL to access Azure Data Explorer Web UI"
  value       = "https://dataexplorer.azure.com/clusters/${azurerm_kusto_cluster.adx_cluster.name}"
}

output "azure_portal_adx_url" {
  description = "URL to access ADX cluster in Azure Portal"
  value       = "https://portal.azure.com/#@${data.azurerm_client_config.current.tenant_id}/resource/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.adx_rg.name}/providers/Microsoft.Kusto/clusters/${azurerm_kusto_cluster.adx_cluster.name}"
}

# Quick Start Information
output "quick_start_info" {
  description = "Quick start information for connecting to ADX"
  value = <<-EOT

🚀 Azure Data Explorer (ADX) Setup Complete!

Cluster Information:
├── Cluster Name: ${azurerm_kusto_cluster.adx_cluster.name}
├── Cluster URI: ${azurerm_kusto_cluster.adx_cluster.uri}
├── Database Name: ${azurerm_kusto_database.tracing_db.name}
└── Resource Group: ${azurerm_resource_group.adx_rg.name}

🔗 Quick Access Links:
├── ADX Web UI: https://dataexplorer.azure.com/clusters/${azurerm_kusto_cluster.adx_cluster.name}
└── Azure Portal: https://portal.azure.com/#resource/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.adx_rg.name}/providers/Microsoft.Kusto/clusters/${azurerm_kusto_cluster.adx_cluster.name}

📊 Security Tables Created:
├── OTelTraces: OpenTelemetry trace data
├── SecurityTraces: Security test results
└── LLMInteractions: LLM usage and cost data

🔍 Sample KQL Queries:
├── List all security traces: SecurityTraces | take 10
├── Get recent vulnerabilities: GetSecurityVulnerabilities("HIGH")
├── Analyze LLM costs: GetLLMCostAnalysis(7)
├── Check failed operations: GetFailedOperations(1)
├── Security test metrics: GetSecurityTestMetrics(7)
└── Top vulnerable targets: GetTopVulnerableTargets(7)

📝 Next Steps:
1. Run: terraform output env_variables > .env
2. Execute the pen-testing tracing notebook
3. Generate 100+ sample traces
4. Use the provided KQL queries for analysis
5. Set up dashboards in Azure portal

💰 Cost Optimization:
├── Auto-stop enabled: ${var.enable_adx_auto_stop}
├── SKU: ${var.adx_sku_name}
├── Capacity: ${var.adx_capacity} instance(s)
└── Hot cache period: ${var.adx_hot_cache_period}

🔐 Authentication:
Use Azure CLI: az login
Or use managed identity for automated access
EOT
}

# Terraform State Information
output "terraform_workspace" {
  description = "Terraform workspace information"
  value = {
    subscription_id = data.azurerm_client_config.current.subscription_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
    environment    = var.environment
    location       = var.location
    unique_suffix  = random_string.unique.result
  }
}
