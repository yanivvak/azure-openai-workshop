# Configure the Azure Provider
terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  storage_use_azuread = true
}

# Configure the AzAPI provider for Azure AI Foundry
provider "azapi" {
}

# Current Azure configuration
data "azurerm_client_config" "current" {}

# Generate a random string for unique naming
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

# Create a resource group
resource "azurerm_resource_group" "foundry_rg" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "rg-foundry-${random_string.unique.result}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    CreatedBy   = "Terraform"
    CreatedOn   = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Create Azure AI Foundry (using AzAPI provider as recommended by Microsoft)
resource "azapi_resource" "ai_foundry" {
  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = var.ai_foundry_name != "" ? var.ai_foundry_name : "foundry-${random_string.unique.result}"
  parent_id                 = azurerm_resource_group.foundry_rg.id
  location                  = azurerm_resource_group.foundry_rg.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"
    sku = {
      name = var.sku_name
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      # Support both Entra ID and API Key authentication
      disableLocalAuth = var.disable_local_auth
      
      # Specifies that this is an AI Foundry resource
      allowProjectManagement = true
      
      # Set custom subdomain name for DNS names created for this Foundry resource
      customSubDomainName = var.ai_foundry_name != "" ? var.ai_foundry_name : "foundry-${random_string.unique.result}"
      
      # Set public network access
      publicNetworkAccess = var.public_network_access_enabled ? "Enabled" : "Disabled"
    }
  }

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    Purpose     = "AI Foundry Account"
    CreatedBy   = "Terraform"
  }
}

# Create AI Foundry Project
resource "azapi_resource" "ai_foundry_project" {
  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = var.project_name != "" ? var.project_name : "${azapi_resource.ai_foundry.name}-project"
  parent_id                 = azapi_resource.ai_foundry.id
  location                  = azurerm_resource_group.foundry_rg.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = var.sku_name
    }
    identity = {
      type = "SystemAssigned"
    }
    properties = {
      displayName = var.project_display_name != "" ? var.project_display_name : "AI Foundry Project"
      description = "Azure AI Foundry project for workshop"
    }
  }

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    Purpose     = "AI Foundry Project"
    CreatedBy   = "Terraform"
  }

  depends_on = [
    azapi_resource.ai_foundry
  ]
}

# Optional: Create a GPT-4.1 model deployment
resource "azurerm_cognitive_deployment" "gpt41_deployment" {
  count                = var.deploy_model ? 1 : 0
  name                 = "gpt-4.1"
  cognitive_account_id = azapi_resource.ai_foundry.id

  depends_on = [
    azapi_resource.ai_foundry
  ]

  model {
    format  = "OpenAI"
    name    = "gpt-4.1"
    version = "2025-04-14"
  }

  scale {
    type     = "GlobalStandard"
    capacity = var.model_capacity
  }

  rai_policy_name = "Microsoft.Default"

  lifecycle {
    ignore_changes = [
      model[0].version
    ]
  }
}

# Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "foundry_workspace" {
  name                = "${azapi_resource.ai_foundry.name}-workspace"
  location            = azurerm_resource_group.foundry_rg.location
  resource_group_name = azurerm_resource_group.foundry_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    Purpose     = "AI Foundry Logging"
    CreatedBy   = "Terraform"
  }
}

# Application Insights for observability and tracing
resource "azurerm_application_insights" "foundry_insights" {
  name                = "${azapi_resource.ai_foundry.name}-insights"
  location            = azurerm_resource_group.foundry_rg.location
  resource_group_name = azurerm_resource_group.foundry_rg.name
  workspace_id        = azurerm_log_analytics_workspace.foundry_workspace.id
  application_type    = "web"

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    Purpose     = "AI Foundry Observability"
    CreatedBy   = "Terraform"
  }
}
