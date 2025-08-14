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

# Set default values (matching Terraform defaults)
DEFAULT_LOCATION="Sweden Central"
DEFAULT_RG_PREFIX="rg-foundry"
DEFAULT_FOUNDRY_PREFIX="foundry"
DEFAULT_ENVIRONMENT="dev"
DEFAULT_SKU="S0"

# Prompt for parameters
read -p "Enter location [${DEFAULT_LOCATION}]: " LOCATION
LOCATION=${LOCATION:-$DEFAULT_LOCATION}

read -p "Enter environment (dev/test/staging/prod) [${DEFAULT_ENVIRONMENT}]: " ENVIRONMENT
ENVIRONMENT=${ENVIRONMENT:-$DEFAULT_ENVIRONMENT}

read -p "Enter resource group name prefix [${DEFAULT_RG_PREFIX}]: " RG_PREFIX
RG_PREFIX=${RG_PREFIX:-$DEFAULT_RG_PREFIX}

read -p "Enter AI Foundry name prefix [${DEFAULT_FOUNDRY_PREFIX}]: " FOUNDRY_PREFIX
FOUNDRY_PREFIX=${FOUNDRY_PREFIX:-$DEFAULT_FOUNDRY_PREFIX}

read -p "Enter SKU (S0/F0) [${DEFAULT_SKU}]: " SKU_NAME
SKU_NAME=${SKU_NAME:-$DEFAULT_SKU}

# Generate unique names
TIMESTAMP=$(date +%s)
UNIQUE_ID=$(echo -n "${SUBSCRIPTION_ID}${TIMESTAMP}" | md5sum | cut -c1-8)
RESOURCE_GROUP_NAME="${RG_PREFIX}-${UNIQUE_ID}"
AI_FOUNDRY_NAME="${FOUNDRY_PREFIX}-${UNIQUE_ID}"
PROJECT_NAME="${AI_FOUNDRY_NAME}-project"

echo ""
echo -e "${YELLOW}📋 Deployment Configuration:${NC}"
echo "  Location: ${LOCATION}"
echo "  Environment: ${ENVIRONMENT}"
echo "  Resource Group: ${RESOURCE_GROUP_NAME}"
echo "  AI Foundry Name: ${AI_FOUNDRY_NAME}"
echo "  Project Name: ${PROJECT_NAME}"
echo "  SKU: ${SKU_NAME}"
echo ""

read -p "Deploy GPT-4.1-mini model? (y/n) [y]: " DEPLOY_MODEL
DEPLOY_MODEL=${DEPLOY_MODEL:-y}
if [[ $DEPLOY_MODEL =~ ^[Yy]$ ]]; then
    DEPLOY_MODEL_PARAM="true"
else
    DEPLOY_MODEL_PARAM="false"
fi

read -p "Model capacity (TPM in thousands, 1-1000) [100]: " MODEL_CAPACITY
MODEL_CAPACITY=${MODEL_CAPACITY:-100}

read -p "Disable local auth (recommended for production) (y/n) [y]: " DISABLE_LOCAL_AUTH
DISABLE_LOCAL_AUTH=${DISABLE_LOCAL_AUTH:-y}
if [[ $DISABLE_LOCAL_AUTH =~ ^[Yy]$ ]]; then
    DISABLE_LOCAL_AUTH_PARAM="true"
else
    DISABLE_LOCAL_AUTH_PARAM="false"
fi

read -p "Enable public network access (y/n) [y]: " PUBLIC_NETWORK
PUBLIC_NETWORK=${PUBLIC_NETWORK:-y}
if [[ $PUBLIC_NETWORK =~ ^[Yy]$ ]]; then
    PUBLIC_NETWORK_PARAM="true"
else
    PUBLIC_NETWORK_PARAM="false"
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

# Deploy using Bicep with parameters file if it exists, otherwise use parameters
if [ -f "parameters.bicepparam" ]; then
    echo "Using parameters file..."
    az deployment sub create \
        --name "${DEPLOYMENT_NAME}" \
        --location "${LOCATION}" \
        --template-file main.bicep \
        --parameters parameters.bicepparam \
        --parameters \
            resourceGroupName="${RESOURCE_GROUP_NAME}" \
            location="${LOCATION}" \
            environment="${ENVIRONMENT}" \
            aiFoundryName="${AI_FOUNDRY_NAME}" \
            projectName="${PROJECT_NAME}" \
            skuName="${SKU_NAME}" \
            deployModel="${DEPLOY_MODEL_PARAM}" \
            modelCapacity="${MODEL_CAPACITY}" \
            disableLocalAuth="${DISABLE_LOCAL_AUTH_PARAM}" \
            publicNetworkAccessEnabled="${PUBLIC_NETWORK_PARAM}" \
        --verbose
else
    echo "Using inline parameters..."
    az deployment sub create \
        --name "${DEPLOYMENT_NAME}" \
        --location "${LOCATION}" \
        --template-file main.bicep \
        --parameters \
            resourceGroupName="${RESOURCE_GROUP_NAME}" \
            location="${LOCATION}" \
            environment="${ENVIRONMENT}" \
            aiFoundryName="${AI_FOUNDRY_NAME}" \
            projectName="${PROJECT_NAME}" \
            skuName="${SKU_NAME}" \
            deployModel="${DEPLOY_MODEL_PARAM}" \
            modelCapacity="${MODEL_CAPACITY}" \
            disableLocalAuth="${DISABLE_LOCAL_AUTH_PARAM}" \
            publicNetworkAccessEnabled="${PUBLIC_NETWORK_PARAM}" \
        --verbose
fi

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
        echo "  AI Project Name: $(echo $OUTPUTS | jq -r '.aiFoundryProjectName.value // "N/A"')"
        echo "  Model Deployment: $(echo $OUTPUTS | jq -r '.modelDeploymentName.value // "N/A"')"
        echo "  Application Insights: $(echo $OUTPUTS | jq -r '.applicationInsightsName.value // "N/A"')"
        
        # Output environment variables if available (secure outputs won't show in JSON)
        echo ""
        echo -e "${YELLOW}🔧 Environment Variables (.env format):${NC}"
        echo "# Copy these values to your .env file:"
        echo ""
        
        # Get individual values to construct the .env output
        ENDPOINT=$(echo $OUTPUTS | jq -r '.azureOpenAIEndpoint.value // .aiFoundryEndpoint.value // "N/A"')
        DEPLOYMENT_NAME=$(echo $OUTPUTS | jq -r '.azureOpenAIDeploymentName.value // .modelDeploymentName.value // "gpt-4.1-mini"')
        API_VERSION=$(echo $OUTPUTS | jq -r '.azureOpenAIApiVersion.value // "2024-10-21"')
        PROJECT_CONN=$(echo $OUTPUTS | jq -r '.projectConnectionString.value // "N/A"')
        APP_INSIGHTS_CONN=$(echo $OUTPUTS | jq -r '.applicationInsightsConnectionString.value // "N/A"')
        PROJECT_ENDPOINT=$(echo $OUTPUTS | jq -r '.aiFoundryProjectEndpoint.value // "N/A"')
        
        # Display the environment variables
        echo "AZURE_OPENAI_ENDPOINT=${ENDPOINT}"
        echo "AZURE_OPENAI_DEPLOYMENT_NAME=${DEPLOYMENT_NAME}"
        echo "AZURE_OPENAI_API_VERSION=${API_VERSION}"
        echo ""
        echo "PROJECT_CONNECTION_STRING=${PROJECT_CONN}"
        echo "APPLICATION_INSIGHTS_CONNECTION_STRING=${APP_INSIGHTS_CONN}"
        echo "PROJECT_ENDPOINT=${PROJECT_ENDPOINT}"
        
        # Save to .env file in project root
        ENV_FILE="../../.env"
        echo ""
        echo -e "${YELLOW}💾 Saving environment variables to ${ENV_FILE}...${NC}"
        
        cat > "${ENV_FILE}" << EOF
# Azure AI Foundry Workshop Environment Variables
# Generated automatically by Bicep deployment on $(date)

# Azure OpenAI Endpoint (REQUIRED)
# This is the AI Foundry resource endpoint from your deployment
AZURE_OPENAI_ENDPOINT=${ENDPOINT}
AZURE_OPENAI_DEPLOYMENT_NAME=${DEPLOYMENT_NAME}
AZURE_OPENAI_API_VERSION=${API_VERSION}

PROJECT_CONNECTION_STRING=${PROJECT_CONN}
APPLICATION_INSIGHTS_CONNECTION_STRING=${APP_INSIGHTS_CONN}
PROJECT_ENDPOINT=${PROJECT_ENDPOINT}

# Azure OpenAI API Key (REQUIRED for key-based auth)
# Get this from Azure Portal -> Your AI Foundry resource -> Keys and Endpoint
# Use either KEY1 or KEY2. Leave commented if using Entra ID authentication
# AZURE_OPENAI_API_KEY=your-api-key-here

# ===== AUTHENTICATION METHOD =====
# Choose your authentication method:
# 1. For Key-based authentication: Set AZURE_OPENAI_API_KEY above
# 2. For Entra ID authentication (recommended): Keep AZURE_OPENAI_API_KEY commented
EOF
        
        echo -e "${GREEN}✅ Environment variables saved to ${ENV_FILE}${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🌐 Access your AI Foundry:${NC}"
    echo "  Portal: https://ai.azure.com"
    echo "  Resource Group Portal: https://portal.azure.com/#@/resource/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/overview"
    echo ""
    echo -e "${YELLOW}💾 Save outputs to file:${NC}"
    echo "  az deployment sub show --name \"${DEPLOYMENT_NAME}\" --query properties.outputs --output json > outputs.json"
    echo ""
    echo -e "${YELLOW}🧹 To clean up resources later:${NC}"
    echo "  az group delete --name \"${RESOURCE_GROUP_NAME}\" --yes --no-wait"
    
else
    echo -e "${RED}❌ Deployment failed. Check the error messages above.${NC}"
    exit 1
fi
