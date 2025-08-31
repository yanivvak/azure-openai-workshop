#!/bin/bash

# Azure AI Foundry Terraform Deployment Script
# This script deploys Azure AI Foundry resources using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN} Azure AI Foundry Terraform Deployment${NC}"
echo "============================================="

# Check prerequisites
echo -e "${BLUE} Checking prerequisites...${NC}"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED} Terraform is not installed. Please install it first.${NC}"
    echo "Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED} Azure CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW} Please log in to Azure CLI first${NC}"
    az login
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo -e "${GREEN} Prerequisites check passed${NC}"
echo -e "${GREEN} Using subscription: ${SUBSCRIPTION_NAME} (${SUBSCRIPTION_ID})${NC}"

# Initialize Terraform
echo ""
echo -e "${BLUE} Initializing Terraform...${NC}"
terraform init

if [ $? -ne 0 ]; then
    echo -e "${RED} Terraform initialization ❌ failed${NC}"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW} terraform.tfvars not found. Using default values.${NC}"
    echo "You can create terraform.tfvars from terraform.tfvars.example to customize settings."
    
    read -p "Continue with default values? (y/n) [y]: " USE_DEFAULTS
    USE_DEFAULTS=${USE_DEFAULTS:-y}
    
    if [[ ! $USE_DEFAULTS =~ ^[Yy]$ ]]; then
        echo "Please create terraform.tfvars and run the script again."
        exit 0
    fi
fi

# Plan the deployment
echo ""
echo -e "${BLUE} Planning deployment...${NC}"
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED} Terraform plan ❌ failed${NC}"
    exit 1
fi

# Show what will be created
echo ""
echo -e "${YELLOW} Deployment Summary:${NC}"
terraform show -no-color tfplan | grep -E "^  # " | head -10

echo ""
read -p "Continue with deployment? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply the configuration
echo ""
echo -e "${BLUE} Applying Terraform configuration...${NC}"
terraform apply tfplan

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN} Deployment completed ✅ successfully!${NC}"
    
    # Clean up plan file
    rm -f tfplan
    
    echo ""
    echo -e "${YELLOW} Deployment Outputs:${NC}"
    terraform output
    
    echo ""
    echo -e "${GREEN} Environment Variables for .env file:${NC}"
    echo "Copy these values to your .env file:"
    echo "----------------------------------------"
    terraform output -raw env_variables
    echo "----------------------------------------"
    
    echo ""
    echo -e "${GREEN} Next Steps:${NC}"
    echo "1. Visit the Azure AI Foundry portal: https://ai.azure.com"
    echo "2. Find your resource in the Azure portal"
    echo "3. Copy the environment variables above to your .env file"
    echo "4. Start building your AI applications!"
    
    echo ""
    echo -e "${YELLOW} Access Keys (if needed):${NC}"
    echo "Primary key: \$(terraform output -raw ai_foundry_primary_access_key)"
    echo "Secondary key: \$(terraform output -raw ai_foundry_secondary_access_key)"
    
    echo ""
    echo -e "${YELLOW} To clean up resources later:${NC}"
    echo "terraform destroy"
    
else
    echo -e "${RED} Deployment ❌ failed. Check the ❌ error messages above.${NC}"
    rm -f tfplan
    exit 1
fi
