# Azure Data Explorer (ADX) Setup for Security Pen-Testing

This directory contains the infrastructure and setup scripts for deploying Azure Data Explorer to support security pen-testing tracing and analytics.

## What's Deployed

The Terraform configuration creates:
- **Azure Data Explorer Cluster** (`adx-viytdz`)
- **TracingDB Database** for storing security traces
- **Storage Account** (`adxstorageviytdz`) for data archiving
- **Event Hub** (`tracing-hub`) for streaming data ingestion
- **EventHub Data Connection** for automatic data ingestion
- **IAM Roles** for secure access between services

## Cluster Information

- **Cluster URI**: `https://adx-viytdz.eastus.kusto.windows.net`
- **Database**: `TracingDB`
- **Web UI**: `https://dataexplorer.azure.com/clusters/adx-viytdz.eastus/databases/TracingDB`
- **Resource Group**: `rg-adx-viytdz`

## Setup Status

| Component | Status | Action Required |
|-----------|--------|-----------------|
| Infrastructure | ✅ Complete | None |
| Database Schema | ✅ Complete | None |
| Data Connection | ✅ Complete | None |
| Environment Variables | ✅ Complete | Source `.env` file |

## Quick Setup (Recommended)

For new deployments, use the automated setup:

```bash
cd /Users/yanivwork/azure-openai-workshop/adx/terraform

```bash
# ✅ Complete setup (infrastructure + schema + connections)
./deploy-adx-complete.sh

# Load environment variables
source ../../.env
```

## Advanced Setup (Infrastructure Only)

If you prefer to set up the schema manually:

### Step 1: Deploy Infrastructure Only
```bash
./deploy-adx-complete.sh
```

### Step 2: Manual Schema Setup (if needed)
```bash
# Open ADX Web UI and run the KQL commands from: ../schema/complete-schema-setup.kql
```
```

## Advanced Setup (Infrastructure Only)

If you prefer to set up the schema manually:

### Step 1: Deploy Infrastructure Only
```bash
./deploy-adx-standalone.sh
```

### Step 2: Manual Schema Setup
```bash
# Open ADX Web UI and run the KQL commands from: ✅ # ../schema/✅ complete-schema-setup.kql
```

### Step 3: Load Environment Variables
```bash
source ../../.env
```

## Validation

Verify your setup is working:

```bash
./validate-adx-setup.sh
```

## Available Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `deploy-adx-complete.sh` | ✅ Complete automated setup | First-time setup (recommended) |
| `validate-adx-setup.sh` | Verify setup works | Troubleshooting, post-setup |
## Sample KQL Queries

Once setup is ✅ complete, try these queries:

```kql
// View recent security traces
SecurityTraces | take 10

// Get high-severity vulnerabilities
GetSecurityVulnerabilities("HIGH")

// Analyze LLM costs over 7 days
GetLLMCostAnalysis(7)

// Check ❌ failed operations
GetFailedOperations(1)

// Security test metrics
GetSecurityTestMetrics(7)

// Find top vulnerable targets
GetTopVulnerableTargets(7)
```

## File Structure

| File | Purpose |
|------|---------|
| `deploy-adx-complete.sh` | ✅ Complete automated setup (recommended) |
| `validate-adx-setup.sh` | Verify setup works correctly |
| `main.tf` | Main Terraform configuration |
| `../schema/complete-schema-setup.kql` | Database schema and functions |

## Quick Actions

```bash
# ✅ Complete automated setup
./deploy-adx-complete.sh

# Verify setup works
./validate-adx-setup.sh
```

## Cost Management

- **Auto-stop enabled**: Cluster stops automatically when inactive
- **SKU**: Dev(No SLA)_Standard_E2a_v4 (cost-optimized)
- **Capacity**: 1 instance
- **Monitor**: Use Azure Portal to track costs

## Security Features

- **System-assigned identity** for Azure resource access
- **RBAC roles** configured for Event Hub and Storage
- **TLS 1.2** minimum for storage account
- **Disk encryption** enabled on ADX cluster
- **Shared key access** enabled for ADX integration

## Troubleshooting

### Common Issues

1. **Cluster stopped**: Use `az rest --method POST --uri "https://management.azure.com/subscriptions/.../start?api-version=2023-08-15"`
2. **Connection URI issues**: Use the correct regional URI with `.eastus.kusto.windows.net`
3. **❌ Permission denied**: Ensure you're logged into Azure CLI (`az login`)
4. **Storage access issues**: Shared key access and public network access are enabled automatically

### Getting Help

1. Check the deployment logs
2. Verify Azure CLI authentication: `az account show`
3. Check cluster status: `az resource show --ids "..."`
4. Review Terraform output: `terraform output`

## Success Criteria

- All infrastructure deployed  
- Database schema created (3 tables, 3 mappings, 7 functions)  
- EventHub data connection established  
- Environment variables configured  
- Ready for security pen-testing analytics

---

**Ready to start security pen-testing analytics with Azure Data Explorer!**
