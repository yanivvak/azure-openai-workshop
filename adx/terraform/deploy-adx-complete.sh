#!/bin/bash

# Azure Data Explorer Complete Setup Script
# This script deploys infrastructure AND sets up the database schema automatically

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${CYAN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║    Azure Data Explorer Complete Setup for Security           ║
    ║                                                               ║
    ║    Infrastructure + Schema + Data Connection                  ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Function to print section headers
print_section() {
    echo ""
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to print step headers
print_step() {
    echo ""
    echo -e "${BLUE}Step $1: $2${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_step "1" "Checking Prerequisites"
    
    local errors=0
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}Azure CLI is not installed${NC}"
        echo "   Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        ((errors++))
    else
        echo -e "${GREEN}Azure CLI found${NC}"
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}Terraform is not installed${NC}"
        echo "   Install from: https://terraform.io/downloads"
        ((errors++))
    else
        echo -e "${GREEN}Terraform found${NC}"
    fi
    
    # Check Azure authentication
    if ! az account show &> /dev/null; then
        echo -e "${RED}Not logged into Azure CLI${NC}"
        echo "   Run: az login"
        ((errors++))
    else
        local account=$(az account show --query "name" -o tsv)
        echo -e "${GREEN}Azure authentication verified${NC}"
        echo -e "${YELLOW}   Account: $account${NC}"
    fi
    
    # Check if schema file exists
    if [ ! -f "../schema/complete-schema-setup.kql" ]; then
        echo -e "${RED}Schema file not found: ../schema/complete-schema-setup.kql${NC}"
        ((errors++))
    else
        echo -e "${GREEN}Schema file found${NC}"
    fi
    
    if [ $errors -gt 0 ]; then
        echo -e "${RED}Please fix the above errors before continuing${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All prerequisites met!${NC}"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_step "2" "Deploying Infrastructure"
    
    echo -e "${YELLOW}⏳ Initializing Terraform...${NC}"
    terraform init
    
    echo -e "${YELLOW}⏳ Planning Terraform deployment...${NC}"
    terraform plan
    
    echo -e "${YELLOW}⏳ Applying Terraform configuration...${NC}"
    echo -e "${YELLOW}   This may take 10-15 minutes for ADX cluster creation...${NC}"
    
    if terraform apply -auto-approve; then
        echo -e "${GREEN}[SUCCESS] Infrastructure deployment completed successfully${NC}"
    else
        echo -e "${RED}[ERROR] Infrastructure deployment failed${NC}"
        exit 1
    fi
    
    # Get cluster information
    local cluster_uri=$(terraform output -raw adx_cluster_uri 2>/dev/null || echo "https://adx-viytdz.eastus.kusto.windows.net")
    local database_name=$(terraform output -raw adx_database_name 2>/dev/null || echo "TracingDB")
    
    echo -e "${GREEN}[INFO] Cluster URI: $cluster_uri${NC}"
    echo -e "${GREEN}[INFO] Database: $database_name${NC}"
    
    # Export for use by schema setup
    export ADX_CLUSTER_URI="$cluster_uri"
    export ADX_DATABASE_NAME="$database_name"
}

# Function to wait for cluster to be ready
wait_for_cluster() {
    print_step "3" "Waiting for Cluster to be Ready"
    
    echo -e "${YELLOW}⏳ Checking cluster status...${NC}"
    
    local max_attempts=20
    local attempt=1
    local cluster_state=""
    
    while [ $attempt -le $max_attempts ]; do
        cluster_state=$(az kusto cluster show --name "adx-viytdz" --resource-group "rg-adx-viytdz" --query "state" -o tsv 2>/dev/null || echo "Unknown")
        
        echo -e "${YELLOW}   Attempt $attempt/$max_attempts - Cluster state: $cluster_state${NC}"
        
        if [ "$cluster_state" = "Running" ]; then
            echo -e "${GREEN}[SUCCESS] Cluster is running and ready${NC}"
            return 0
        elif [ "$cluster_state" = "Stopped" ]; then
            echo -e "${YELLOW}[STARTING] Starting stopped cluster...${NC}"
            az kusto cluster start --name "adx-viytdz" --resource-group "rg-adx-viytdz" --no-wait
        fi
        
        echo -e "${YELLOW}   Waiting 60 seconds before next check...${NC}"
        sleep 60
        ((attempt++))
    done
    
    echo -e "${RED}[ERROR] Cluster did not become ready within expected time${NC}"
    echo -e "${YELLOW}[WARNING] You may need to manually start the cluster and re-run schema setup${NC}"
    return 1
}

# Function to setup database schema
setup_database_schema() {
    print_step "4" "Setting up Database Schema"
    
    echo -e "${YELLOW}⏳ Running automated schema setup...${NC}"
    
    if ./setup-adx-schema.sh; then
        echo -e "${GREEN}[SUCCESS] Database schema setup completed successfully${NC}"
    else
        echo -e "${RED}[ERROR] Database schema setup failed${NC}"
        echo -e "${YELLOW}[WARNING] You may need to run the schema setup manually${NC}"
        return 1
    fi
}

# Function to finalize setup
finalize_setup() {
    print_step "5" "Finalizing Setup"
    
    echo -e "${YELLOW}⏳ Running final Terraform apply to create data connections...${NC}"
    
    # Run terraform apply again to create any remaining resources
    # (data connections that require the schema to exist)
    if terraform apply -auto-approve; then
        echo -e "${GREEN}[SUCCESS] Data connections created successfully${NC}"
    else
        echo -e "${YELLOW}[WARNING] Data connection creation may have failed, but infrastructure is ready${NC}"
        echo -e "${YELLOW}   You can manually create data connections later if needed${NC}"
    fi
    
    # Update environment variables
    echo -e "${YELLOW}⏳ Updating environment variables...${NC}"
    
    # Get outputs and append to .env file
    local env_file="../../.env"
    local cluster_uri=$(terraform output -raw adx_cluster_uri 2>/dev/null || echo "https://adx-viytdz.eastus.kusto.windows.net")
    local database_name=$(terraform output -raw adx_database_name 2>/dev/null || echo "TracingDB")
    
    # Remove old ADX entries if they exist
    if [ -f "$env_file" ]; then
        grep -v "^ADX_" "$env_file" > "${env_file}.tmp" && mv "${env_file}.tmp" "$env_file" 2>/dev/null || true
    fi
    
    # Add new ADX entries
    cat >> "$env_file" << EOF

# Azure Data Explorer Configuration
ADX_CLUSTER_URI=$cluster_uri
ADX_DATABASE_NAME=$database_name
ADX_WEB_UI=https://dataexplorer.azure.com/clusters/adx-viytdz.eastus/databases/TracingDB
EOF
    
    echo -e "${GREEN}[SUCCESS] Environment variables updated in $env_file${NC}"
}

# Function to print success summary
print_success_summary() {
    print_section "🎉 SETUP COMPLETED SUCCESSFULLY!"
    
    echo -e "${GREEN}[SUCCESS] Infrastructure deployed and configured${NC}"
    echo -e "${GREEN}[SUCCESS] Database schema created (3 tables, 3 mappings, 7 functions)${NC}"
    echo -e "${GREEN}[SUCCESS] Data connections established${NC}"
    echo -e "${GREEN}[SUCCESS] Environment variables configured${NC}"
    echo ""
    echo -e "${BLUE}🔗 What's Next:${NC}"
    echo ""
    echo -e "${YELLOW}1. Load environment variables:${NC}"
    echo -e "   ${CYAN}source ../../.env${NC}"
    echo ""
    echo -e "${YELLOW}2. Open ADX Web UI:${NC}"
    echo -e "   ${CYAN}https://dataexplorer.azure.com/clusters/adx-viytdz.eastus/databases/TracingDB${NC}"
    echo ""
    echo -e "${YELLOW}3. Test with sample queries:${NC}"
    echo -e "   ${CYAN}SecurityTraces | take 10${NC}"
    echo -e "   ${CYAN}GetSecurityVulnerabilities(\"HIGH\")${NC}"
    echo ""
    echo -e "${YELLOW}4. Run the security notebook:${NC}"
    echo -e "   ${CYAN}../notebooks/03-security-pentesting-adx.ipynb${NC}"
    echo ""
    echo -e "${GREEN}[STARTING] Azure Data Explorer is ready for security pen-testing analytics!${NC}"
    echo ""
}

# Main execution flow
main() {
    # Check if destroy flag is passed
    if [[ "$1" == "--destroy" ]]; then
        echo -e "${RED}🗑️  Destroying Azure Data Explorer infrastructure...${NC}"
        terraform destroy -auto-approve
        echo -e "${GREEN}[SUCCESS] Infrastructure destroyed${NC}"
        exit 0
    fi
    
    # Check if help flag is passed
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "Azure Data Explorer Complete Setup"
        echo ""
        echo "Usage:"
        echo "  ./deploy-adx-complete.sh           Deploy complete ADX infrastructure"
        echo "  ./deploy-adx-complete.sh --destroy Destroy ADX infrastructure"
        echo "  ./deploy-adx-complete.sh --help    Show this help message"
        echo ""
        exit 0
    fi
    
    # Main setup flow
    check_prerequisites
    deploy_infrastructure
    wait_for_cluster
    setup_database_schema
    finalize_setup
    print_success_summary
}

# Run main function with all arguments
main "$@"
