# Standalone variables for Azure Data Explorer (ADX) deployment

# Basic Configuration
variable "location" {
  description = "Azure region for ADX resources"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3", "Central US", "North Central US", "South Central US",
      "North Europe", "West Europe", "UK South", "UK West", "France Central",
      "Southeast Asia", "East Asia", "Australia East", "Australia Southeast",
      "Japan East", "Japan West", "Korea Central", "South India", "Central India",
      "Canada Central", "Canada East", "Brazil South"
    ], var.location)
    error_message = "Location must be a valid Azure region that supports Azure Data Explorer."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group (leave empty for auto-generated)"
  type        = string
  default     = ""
}

# ADX Cluster Variables
variable "adx_cluster_name" {
  description = "Name of the Azure Data Explorer cluster (leave empty for auto-generated)"
  type        = string
  default     = ""
  
  validation {
    condition     = var.adx_cluster_name == "" || can(regex("^[a-z0-9]{4,22}$", var.adx_cluster_name))
    error_message = "ADX cluster name must be 4-22 characters long, lowercase letters and numbers only."
  }
}

variable "adx_sku_name" {
  description = "SKU name for the ADX cluster"
  type        = string
  default     = "Dev(No SLA)_Standard_E2a_v4"
  
  validation {
    condition = contains([
      "Dev(No SLA)_Standard_E2a_v4",
      "Standard_E2a_v4",
      "Standard_E4a_v4", 
      "Standard_E8a_v4",
      "Standard_E16a_v4",
      "Standard_E2ads_v5",
      "Standard_E4ads_v5",
      "Standard_E8ads_v5"
    ], var.adx_sku_name)
    error_message = "ADX SKU must be a valid Azure Data Explorer SKU name."
  }
}

variable "adx_capacity" {
  description = "Capacity (number of instances) for the ADX cluster"
  type        = number
  default     = 1
  
  validation {
    condition     = var.adx_capacity >= 1 && var.adx_capacity <= 1000
    error_message = "ADX capacity must be between 1 and 1000."
  }
}

variable "adx_database_name" {
  description = "Name of the ADX database for tracing data"
  type        = string
  default     = "TracingDB"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_]{1,260}$", var.adx_database_name))
    error_message = "ADX database name must be 1-260 characters long, letters, numbers, and underscores only."
  }
}

variable "enable_adx_auto_stop" {
  description = "Enable auto-stop for the ADX cluster to save costs"
  type        = bool
  default     = true
}

variable "adx_hot_cache_period" {
  description = "Hot cache period for ADX database (e.g., P7D for 7 days)"
  type        = string
  default     = "P7D"
  
  validation {
    condition     = can(regex("^P[0-9]+D$", var.adx_hot_cache_period))
    error_message = "Hot cache period must be in ISO 8601 duration format (e.g., P7D for 7 days)."
  }
}

variable "adx_soft_delete_period" {
  description = "Soft delete period for ADX database (e.g., P30D for 30 days)"
  type        = string
  default     = "P30D"
  
  validation {
    condition     = can(regex("^P[0-9]+D$", var.adx_soft_delete_period))
    error_message = "Soft delete period must be in ISO 8601 duration format (e.g., P30D for 30 days)."
  }
}

# Event Hub Variables
variable "eventhub_partition_count" {
  description = "Number of partitions for the Event Hub"
  type        = number
  default     = 2
  
  validation {
    condition     = var.eventhub_partition_count >= 1 && var.eventhub_partition_count <= 32
    error_message = "Event Hub partition count must be between 1 and 32."
  }
}

variable "eventhub_message_retention" {
  description = "Message retention in days for Event Hub"
  type        = number
  default     = 1
  
  validation {
    condition     = var.eventhub_message_retention >= 1 && var.eventhub_message_retention <= 7
    error_message = "Event Hub message retention must be between 1 and 7 days."
  }
}

# Security and Tracing Variables
variable "enable_security_tracing" {
  description = "Enable security-focused tracing tables and functions"
  type        = bool
  default     = true
}

variable "trace_retention_days" {
  description = "Number of days to retain trace data"
  type        = number
  default     = 30
  
  validation {
    condition     = var.trace_retention_days >= 1 && var.trace_retention_days <= 365
    error_message = "Trace retention days must be between 1 and 365."
  }
}

variable "enable_cost_monitoring" {
  description = "Enable cost monitoring for LLM interactions"
  type        = bool
  default     = true
}

# Pen Testing Scenario Variables
variable "pen_test_environments" {
  description = "List of environments for pen testing scenarios"
  type        = list(string)
  default     = ["development", "staging", "production"]
}

variable "security_test_types" {
  description = "Types of security tests to support"
  type        = list(string)
  default     = [
    "vulnerability_scan", 
    "penetration_test", 
    "code_analysis", 
    "infrastructure_assessment", 
    "social_engineering",
    "web_application_test",
    "network_security_test",
    "database_security_test",
    "mobile_security_test",
    "cloud_security_test"
  ]
}

variable "severity_levels" {
  description = "Security finding severity levels"
  type        = list(string)
  default     = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO"]
}

# Resource Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
