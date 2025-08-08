#!/bin/bash

# Azure AI Foundry Deployment Script
# This script deploys Azure AI Foundry resources using Bicep

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Azure AI Foundry Deployment Script${NC}"
echo "=========================================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️ Please log in to Azure CLI first${NC}"
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo -e "${GREEN}✅ Using subscription: ${SUBSCRIPTION_NAME} (${SUBSCRIPTION_ID})${NC}"

# Set default values
DEFAULT_LOCATION="eastus2"
DEFAULT_RG_PREFIX="rg-foundry"
DEFAULT_FOUNDRY_PREFIX="foundry"

# Prompt for parameters
read -p "Enter location [${DEFAULT_LOCATION}]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "Enter resource group name prefix [${DEFAULT_RG_PREFIX}]: " RG_PREFIX
RG_PREFIX=${RG_PREFIX:-$DEFAULT_RG_PREFIX}

read -p "Enter AI Foundry name prefix [${DEFAULT_FOUNDRY_PREFIX}]: " FOUNDRY_PREFIX
FOUNDRY_PREFIX=${FOUNDRY_PREFIX:-$DEFAULT_FOUNDRY_PREFIX}

# Generate unique names
TIMESTAMP=$(date +%s)
UNIQUE_ID=$(echo -n "${SUBSCRIPTION_ID}${TIMESTAMP}" | md5sum | cut -c1-8)
RESOURCE_GROUP_NAME="${RG_PREFIX}-${UNIQUE_ID}"
AI_FOUNDRY_NAME="${FOUNDRY_PREFIX}-${UNIQUE_ID}"

echo ""
echo -e "${YELLOW}📋 Deployment Configuration:${NC}"
echo "  Location: ${LOCATION}"
echo "  Resource Group: ${RESOURCE_GROUP_NAME}"
echo "  AI Foundry Name: ${AI_FOUNDRY_NAME}"
echo ""

read -p "Deploy GPT-4o model? (y/n) [y]: " DEPLOY_MODEL
DEPLOY_MODEL=${DEPLOY_MODEL:-y}
if [[ $DEPLOY_MODEL =~ ^[Yy]$ ]]; then
    DEPLOY_MODEL_PARAM="true"
else
    DEPLOY_MODEL_PARAM="false"
fi

# Confirm deployment
echo ""
read -p "Continue with deployment? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}🔨 Starting deployment...${NC}"

# Create deployment name
DEPLOYMENT_NAME="foundry-deployment-${TIMESTAMP}"

# Deploy using Bicep
echo "Deploying Bicep template..."
az deployment sub create \
    --name "${DEPLOYMENT_NAME}" \
    --location "${LOCATION}" \
    --template-file main.bicep \
    --parameters \
        resourceGroupName="${RESOURCE_GROUP_NAME}" \
        location="${LOCATION}" \
        aiFoundryName="${AI_FOUNDRY_NAME}" \
        deployModel="${DEPLOY_MODEL_PARAM}" \
    --verbose

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📊 Deployment Details:${NC}"
    
    # Get outputs
    OUTPUTS=$(az deployment sub show --name "${DEPLOYMENT_NAME}" --query properties.outputs --output json)
    
    if [ "$OUTPUTS" != "null" ] && [ "$OUTPUTS" != "{}" ]; then
        echo "  Resource Group: $(echo $OUTPUTS | jq -r '.resourceGroupName.value // "N/A"')"
        echo "  AI Foundry Name: $(echo $OUTPUTS | jq -r '.aiFoundryName.value // "N/A"')"
        echo "  AI Foundry Endpoint: $(echo $OUTPUTS | jq -r '.aiFoundryEndpoint.value // "N/A"')"
        echo "  AI Project Name: $(echo $OUTPUTS | jq -r '.aiProjectName.value // "N/A"')"
    fi
    
    echo ""
    echo -e "${GREEN}🌐 Access your AI Foundry:${NC}"
    echo "  Portal: https://ai.azure.com"
    echo ""
    echo -e "${YELLOW}🧹 To clean up resources later:${NC}"
    echo "  az group delete --name \"${RESOURCE_GROUP_NAME}\" --yes --no-wait"
    
else
    echo -e "${RED}❌ Deployment failed. Check the error messages above.${NC}"
    exit 1
fi
