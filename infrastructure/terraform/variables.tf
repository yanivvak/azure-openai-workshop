# Resource Group Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = ""
}

variable "location" {
  description = "Location for all resources"
  type        = string
  default     = "East US 2"
  
  validation {
    condition = can(regex("^[A-Za-z0-9 ]+$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

# AI Foundry Variables
variable "ai_foundry_name" {
  description = "Name of the AI Foundry resource"
  type        = string
  default     = ""
  
  validation {
    condition     = var.ai_foundry_name == "" || can(regex("^[a-z0-9-]{3,24}$", var.ai_foundry_name))
    error_message = "AI Foundry name must be 3-24 characters long, lowercase letters, numbers, and hyphens only."
  }
}

variable "ai_project_name" {
  description = "Name of the AI Foundry project"
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "SKU for the AI Foundry resource"
  type        = string
  default     = "S0"
  
  validation {
    condition     = contains(["F0", "S0"], var.sku_name)
    error_message = "SKU must be either F0 (free) or S0 (standard)."
  }
}

variable "disable_local_auth" {
  description = "Disable local authentication (recommended for production)"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

# Model Deployment Variables
variable "deploy_model" {
  description = "Deploy a GPT-4o model"
  type        = bool
  default     = true
}

variable "model_capacity" {
  description = "Capacity for the model deployment"
  type        = number
  default     = 1
  
  validation {
    condition     = var.model_capacity >= 1 && var.model_capacity <= 100
    error_message = "Model capacity must be between 1 and 100."
  }
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
