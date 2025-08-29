#!/bin/bash

# Azure Data Explorer Setup Validation Script
# This script validates that the ADX setup is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Validating Azure Data Explorer Setup...${NC}"
echo ""

# Test variables
TESTS_PASSED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -e "${YELLOW}Testing: $test_name${NC}"
    ((TESTS_TOTAL++))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        return 1
    fi
}

# Test 1: Azure CLI authentication
run_test "Azure CLI Authentication" "az account show > /dev/null 2>&1"

# Test 2: Terraform state
run_test "Terraform State" "terraform show > /dev/null 2>&1"

# Test 3: ADX Cluster exists and is running
run_test "ADX Cluster Status" 'az kusto cluster show --name "adx-viytdz" --resource-group "rg-adx-viytdz" --query "state" -o tsv 2>/dev/null | grep -q "Running"'

# Test 4: Database exists
run_test "TracingDB Database" 'az kusto database show --cluster-name "adx-viytdz" --database-name "TracingDB" --resource-group "rg-adx-viytdz" > /dev/null 2>&1'

# Test 5: Environment file exists
run_test "Environment File" "test -f ../../.env"

# Test 6: Schema file exists
run_test "Schema File" "test -f ../schema/complete-schema-setup.kql"

# Test 7: Tables exist (using Azure CLI)
echo -e "${YELLOW}Testing: Database Tables${NC}"
((TESTS_TOTAL++))

tables_exist=true
for table in "OTelTraces" "SecurityTraces" "LLMInteractions"; do
    if ! az kusto table show --cluster-name "adx-viytdz" --database-name "TracingDB" --table-name "$table" --resource-group "rg-adx-viytdz" > /dev/null 2>&1; then
        echo -e "${RED}  ❌ Table '$table' not found${NC}"
        tables_exist=false
    else
        echo -e "${GREEN}  ✅ Table '$table' exists${NC}"
    fi
done

if $tables_exist; then
    echo -e "${GREEN}✅ PASSED: Database Tables${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}❌ FAILED: Database Tables${NC}"
fi

# Test 8: EventHub namespace exists
run_test "EventHub Namespace" 'az eventhubs namespace show --name "tracing-eh-viytdz" --resource-group "rg-adx-viytdz" > /dev/null 2>&1'

# Test 9: Storage account exists
run_test "Storage Account" 'az storage account show --name "adxstorageviytdz" --resource-group "rg-adx-viytdz" > /dev/null 2>&1'

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  VALIDATION SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! ($TESTS_PASSED/$TESTS_TOTAL)${NC}"
    echo ""
    echo -e "${GREEN}✅ Azure Data Explorer setup is working correctly${NC}"
    echo ""
    echo -e "${BLUE}🔗 Ready to use:${NC}"
    echo -e "   • Web UI: ${YELLOW}https://dataexplorer.azure.com/clusters/adx-viytdz.eastus/databases/TracingDB${NC}"
    echo -e "   • Cluster: ${YELLOW}https://adx-viytdz.eastus.kusto.windows.net${NC}"
    echo -e "   • Database: ${YELLOW}TracingDB${NC}"
    echo ""
    echo -e "${BLUE}📝 Next steps:${NC}"
    echo -e "   1. Load environment: ${YELLOW}source ../../.env${NC}"
    echo -e "   2. Run security notebook: ${YELLOW}../notebooks/03-security-pentesting-adx.ipynb${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED ($TESTS_PASSED/$TESTS_TOTAL passed)${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Possible fixes:${NC}"
    echo -e "   • Run the complete setup: ${YELLOW}./deploy-adx-complete.sh${NC}"
    echo -e "   • Check Azure CLI login: ${YELLOW}az login${NC}"
    echo -e "   • Manually setup schema: ${YELLOW}./setup-adx-schema.sh${NC}"
    echo ""
    exit 1
fi
