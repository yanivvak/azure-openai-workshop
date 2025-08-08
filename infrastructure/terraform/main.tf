# Configure the Azure Provider
terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
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
}

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

# Create Azure AI Foundry (Cognitive Services Account)
resource "azurerm_cognitive_account" "ai_foundry" {
  name                          = var.ai_foundry_name != "" ? var.ai_foundry_name : "foundry-${random_string.unique.result}"
  resource_group_name           = azurerm_resource_group.foundry_rg.name
  location                      = azurerm_resource_group.foundry_rg.location
  kind                          = "AIServices"
  sku_name                      = var.sku_name
  custom_subdomain_name         = var.ai_foundry_name != "" ? var.ai_foundry_name : "foundry-${random_string.unique.result}"
  public_network_access_enabled = var.public_network_access_enabled
  local_auth_enabled            = !var.disable_local_auth

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Project     = "Azure Foundry"
    Purpose     = "AI Foundry Account"
    CreatedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [
      tags["CreatedOn"]
    ]
  }
}

# Create AI Foundry Project (this might require additional configuration)
# Note: As of the current Terraform AzureRM provider version, direct project creation 
# might not be fully supported. This may require using the AzAPI provider or Azure CLI.

# Optional: Create a GPT-4o model deployment
resource "azurerm_cognitive_deployment" "gpt4o_deployment" {
  count                = var.deploy_model ? 1 : 0
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o"
    version = "2024-08-06"
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
