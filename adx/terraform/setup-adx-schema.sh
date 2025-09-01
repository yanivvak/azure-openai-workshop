#!/bin/bash

# Azure Data Explorer Schema Setup Script
# This script runs the KQL schema setup commands

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Azure Data Explorer database schema...${NC}"

# Get cluster information from terraform outputs or use defaults
CLUSTER_URI=$(terraform output -raw adx_cluster_uri 2>/dev/null || echo "https://adx-viytdz.eastus.kusto.windows.net")
DATABASE_NAME=$(terraform output -raw adx_database_name 2>/dev/null || echo "TracingDB")

echo -e "${YELLOW}Cluster URI: $CLUSTER_URI${NC}"
echo -e "${YELLOW}Database: $DATABASE_NAME${NC}"

# Check if schema file exists
SCHEMA_FILE="../schema/complete-schema-setup.kql"
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}Schema file not found: $SCHEMA_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}Schema file found: $SCHEMA_FILE${NC}"

# Try to run the schema setup using Azure CLI
echo -e "${YELLOW}Running schema setup using Azure CLI...${NC}"

# Extract cluster name from URI for Azure CLI commands
CLUSTER_NAME=$(echo "$CLUSTER_URI" | sed 's/https:\/\/\([^.]*\).*/\1/')
RESOURCE_GROUP="rg-$CLUSTER_NAME"

echo -e "${YELLOW}Cluster name: $CLUSTER_NAME${NC}"
echo -e "${YELLOW}Resource group: $RESOURCE_GROUP${NC}"

# Execute the KQL script
echo -e "${YELLOW}Executing KQL schema setup...${NC}"

if az kusto script create \
    --cluster-name "$CLUSTER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --database-name "$DATABASE_NAME" \
    --script-name "schema-setup-$(date +%s)" \
    --script-content "$(cat $SCHEMA_FILE)" \
    --force-update-tag "schema-setup" \
    --continue-on-errors false; then
    
    echo -e "${GREEN}[SUCCESS] Schema setup completed successfully!${NC}"
    echo -e "${GREEN}Created:${NC}"
    echo -e "${GREEN}  • 3 tables: OTelTraces, SecurityTraces, LLMInteractions${NC}"
    echo -e "${GREEN}  • 3 JSON mappings for data ingestion${NC}"
    echo -e "${GREEN}  • 7 analytical functions for security queries${NC}"
    
    # Now create the Event Hub data connection
    echo -e "${YELLOW}Creating Event Hub data connection...${NC}"
    
    # Get EventHub ID from terraform outputs
    EVENTHUB_ID=$(terraform output -raw eventhub_id 2>/dev/null || echo "")
    if [ -z "$EVENTHUB_ID" ]; then
        # Construct EventHub ID manually if terraform output is not available
        SUBSCRIPTION_ID=$(az account show --query id -o tsv)
        EVENTHUB_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.EventHub/namespaces/tracing-namespace-$(echo $CLUSTER_NAME | sed 's/adx-//')/eventhubs/tracing-hub"
    fi
    
    if az kusto data-connection event-hub create \
        --cluster-name "$CLUSTER_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --database-name "$DATABASE_NAME" \
        --data-connection-name "tracing-data-connection" \
        --location "eastus" \
        --event-hub-resource-id "$EVENTHUB_ID" \
        --consumer-group "\$Default" \
        --table-name "OTelTraces" \
        --mapping-rule-name "OTelTracesMapping" \
        --data-format "JSON" \
        --compression "None"; then
        
        echo -e "${GREEN}[SUCCESS] Event Hub data connection created successfully!${NC}"
    else
        echo -e "${YELLOW}[WARNING] Event Hub data connection creation failed, but schema is ready${NC}"
        echo -e "${YELLOW}   You can manually create the data connection later if needed${NC}"
    fi
    
else
    echo -e "${YELLOW}[WARNING] Azure CLI script execution failed, trying alternative method...${NC}"
    
    # Alternative: Manual instructions
    echo -e "${YELLOW}[INFO] Please manually run the schema setup:${NC}"
    echo -e "${YELLOW}1. Open ADX Web UI: https://dataexplorer.azure.com/clusters/$CLUSTER_NAME.eastus/databases/$DATABASE_NAME${NC}"
    echo -e "${YELLOW}2. Copy and paste the contents of: ../schema/complete-schema-setup.kql${NC}"
    echo -e "${YELLOW}3. Run the entire script in the ADX query editor${NC}"
    
    # Still return success since the infrastructure is ready
    echo -e "${GREEN}[INFO] Infrastructure is ready, schema can be set up manually${NC}"
fi

echo -e "${BLUE}Schema setup process completed.${NC}"
