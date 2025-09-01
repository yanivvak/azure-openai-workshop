# Azure Data Explorer (ADX) Infrastructure Configuration
# This Terraform configuration deploys a complete ADX setup for security pen-testing analytics

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Generate unique suffix for resource names
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

# Calculate resource names
locals {
  unique_suffix         = random_string.unique.result
  resource_group_name   = var.resource_group_name != "" ? var.resource_group_name : "rg-adx-${local.unique_suffix}"
  adx_cluster_name      = var.adx_cluster_name != "" ? var.adx_cluster_name : "adx-${local.unique_suffix}"
  storage_account_name  = "adxstorage${local.unique_suffix}"
  eventhub_namespace    = "tracing-namespace-${local.unique_suffix}"
  eventhub_name         = "tracing-hub"
  
  # Common tags
  common_tags = merge({
    Environment   = var.environment
    Purpose      = "ADX-Security-Analytics"
    CreatedBy    = "Terraform"
    Project      = "Azure-OpenAI-Workshop"
    UniqueId     = local.unique_suffix
  }, var.additional_tags)
}

# Resource Group
resource "azurerm_resource_group" "adx_rg" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Storage Account for data archiving and temp storage
resource "azurerm_storage_account" "adx_storage" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.adx_rg.name
  location            = azurerm_resource_group.adx_rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  # Security settings
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  shared_access_key_enabled       = true
  allow_nested_items_to_be_public = false

  # Enable blob properties
  blob_properties {
    delete_retention_policy {
      days = var.trace_retention_days
    }
    container_delete_retention_policy {
      days = var.trace_retention_days
    }
  }

  tags = local.common_tags
}

# Storage Container for trace data
resource "azurerm_storage_container" "trace_data" {
  name                  = "trace-data"
  storage_account_name  = azurerm_storage_account.adx_storage.name
  container_access_type = "private"
}

# Event Hub Namespace for streaming data ingestion
resource "azurerm_eventhub_namespace" "tracing_namespace" {
  name                = local.eventhub_namespace
  location            = azurerm_resource_group.adx_rg.location
  resource_group_name = azurerm_resource_group.adx_rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = local.common_tags
}

# Event Hub for trace data
resource "azurerm_eventhub" "tracing_hub" {
  name                = local.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.tracing_namespace.name
  resource_group_name = azurerm_resource_group.adx_rg.name
  partition_count     = var.eventhub_partition_count
  message_retention   = var.eventhub_message_retention

  capture_description {
    enabled  = true
    encoding = "Avro"
    
    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = azurerm_storage_container.trace_data.name
      storage_account_id  = azurerm_storage_account.adx_storage.id
    }
  }
}

# Authorization rule for Event Hub
resource "azurerm_eventhub_authorization_rule" "tracing_hub_rule" {
  name                = "adx-ingestion-rule"
  namespace_name      = azurerm_eventhub_namespace.tracing_namespace.name
  eventhub_name       = azurerm_eventhub.tracing_hub.name
  resource_group_name = azurerm_resource_group.adx_rg.name

  listen = true
  send   = true
  manage = false
}

# Azure Data Explorer Cluster
resource "azurerm_kusto_cluster" "adx_cluster" {
  name                = local.adx_cluster_name
  location            = azurerm_resource_group.adx_rg.location
  resource_group_name = azurerm_resource_group.adx_rg.name

  sku {
    name     = var.adx_sku_name
    capacity = var.adx_capacity
  }

  # Enable system assigned identity
  identity {
    type = "SystemAssigned"
  }

  # Security and optimization settings
  disk_encryption_enabled = true
  streaming_ingestion_enabled = true
  purge_enabled = true
  
  # Auto-stop settings for cost optimization
  auto_stop_enabled = var.enable_adx_auto_stop

  tags = local.common_tags
}

# Azure Data Explorer Database
resource "azurerm_kusto_database" "tracing_db" {
  name                = var.adx_database_name
  resource_group_name = azurerm_resource_group.adx_rg.name
  location            = azurerm_resource_group.adx_rg.location
  cluster_name        = azurerm_kusto_cluster.adx_cluster.name

  hot_cache_period   = var.adx_hot_cache_period
  soft_delete_period = var.adx_soft_delete_period
}

# Role assignment: ADX cluster identity -> Storage Account (Contributor)
resource "azurerm_role_assignment" "adx_storage_contributor" {
  scope                = azurerm_storage_account.adx_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kusto_cluster.adx_cluster.identity[0].principal_id
}

# Role assignment: ADX cluster identity -> Event Hub (Reader)
resource "azurerm_role_assignment" "adx_eventhub_reader" {
  scope                = azurerm_eventhub.tracing_hub.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_kusto_cluster.adx_cluster.identity[0].principal_id
}

# Event Hub Data Connection will be created after schema setup
# Commented out to avoid dependency on tables/mappings that don't exist yet
# This will be created via Azure CLI after schema setup in the deployment script

# resource "azurerm_kusto_eventhub_data_connection" "tracing_connection" {
#   name                = "tracing-data-connection"
#   resource_group_name = azurerm_resource_group.adx_rg.name
#   location            = azurerm_resource_group.adx_rg.location
#   cluster_name        = azurerm_kusto_cluster.adx_cluster.name
#   database_name       = azurerm_kusto_database.tracing_db.name
#
#   eventhub_id         = azurerm_eventhub.tracing_hub.id
#   consumer_group      = "$Default"
#   table_name          = "OTelTraces"
#   mapping_rule_name   = "OTelTracesMapping"
#   data_format         = "JSON"
#   compression         = "None"
#
#   depends_on = [
#     azurerm_kusto_database.tracing_db,
#     azurerm_role_assignment.adx_eventhub_reader
#   ]
# }
