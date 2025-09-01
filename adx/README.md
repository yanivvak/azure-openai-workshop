# Azure Data Explorer (ADX) Integration

This folder contains all Azure Data Explorer (ADX) related components for the Azure OpenAI Workshop, including tracing, security analytics, and cost monitoring capabilities.

## Quick Start for ADX Security Analytics (5 Minutes)

**Want to jump straight to enterprise security analytics?**

### Step 1: Deploy Everything
```bash
cd adx/terraform
./deploy-adx-complete.sh
```
**What this does:** Deploys Azure Data Explorer cluster, database, schema, and all connections automatically.

### Step 2: Load Environment  
```bash
source ../../.env
```
**What this does:** Loads all configuration variables into your environment.

### Step 3: Run the Security Notebook
```bash
# Open the notebook and run all cells
adx/notebooks/03-security-pentesting-adx.ipynb
```
**What this does:** Generates 120+ realistic security tests with AI analysis and exports to ADX.

### Success Criteria

After completing the steps above, you should have:

- ADX cluster running with TracingDB database
- 3 tables with schema: SecurityTraces, LLMInteractions, OTelTraces  
- 7 analytical functions for security queries
- 120+ security test records with AI analysis
- Ready-to-use KQL queries for insights

## Quick Start (Automated Setup)

The **fastest way** to get started:

```bash
cd terraform
./deploy-adx-complete.sh
source ../../.env
```

That's it! Everything is deployed and configured automatically.

**Note:** If the schema setup fails during automated deployment, you can manually complete it by:
1. Opening the ADX Web UI (link provided in deployment output)  
2. Running the contents of `schema/complete-schema-setup.kql`

## Manual Schema Setup (If Needed)

If the automated schema setup fails, complete these steps:

1. **Open ADX Web UI**: Use the URL from deployment output or `.env` file
2. **Copy Schema Script**: Copy all contents from `schema/complete-schema-setup.kql`
3. **Run in ADX**: Paste and execute the entire script in the ADX query editor
4. **Verify**: Run `.show tables` to confirm 3 tables were created

The schema script creates:
- **3 Tables**: OTelTraces, SecurityTraces, LLMInteractions
- **3 JSON Mappings**: For automated data ingestion  
- **7 Functions**: For security analytics queries

## Folder Structure

### `/notebooks`
- **03-security-pentesting-adx.ipynb** - Security pen-testing tracing simulation

### `/terraform`
- **deploy-adx-✅ complete.sh** - ✅ Complete automated setup (recommended)
- **deploy-adx-standalone.sh** - Infrastructure-only deployment
- **validate-adx-setup.sh** - Validate deployment success  
- **adx-standalone.tf** - Terraform configuration
- **README.md** - Detailed setup documentation

### `/schema`
- **complete-schema-setup.kql** - ✅ Complete KQL script with tables, mappings, and functions

## Setup Options

### Option 1: ✅ Complete Automation (Recommended)
```bash
cd terraform
./deploy-adx-complete.sh      # Deploy everything automatically
source ../../.env             # Load environment variables
```

### Option 2: Infrastructure Only
```bash
cd terraform
./deploy-adx-complete.sh      # Deploy infrastructure (schema may need manual setup)  
# Then manually set up schema using ADX Web UI if needed
source ../../.env             # Load environment variables
```

### Option 3: Validation
```bash
cd terraform
./validate-adx-setup.sh     # Check if everything is working
```

## Validation

Check if everything is working:

```bash
cd terraform
./validate-adx-setup.sh
```

## Scripts Overview

- **`deploy-adx-complete.sh`** - One-command setup: infrastructure + schema + connections
- **`validate-adx-setup.sh`** - Verify that everything is working correctly

## What's Deployed

After successful setup you'll have:

- **Azure Data Explorer Cluster** (`adx-viytdz`)
- **TracingDB Database** with 3 tables and 7 analytical functions
- **EventHub Data Connection** for streaming ingestion
- **Storage Account** for data archiving
- **IAM Roles** configured for secure access
- **JSON Mappings** for automated data parsing

## Use Cases

### **Tracing & Monitoring**
- Track OpenAI API calls and token usage
- Monitor application performance and costs
- Analyze user interaction patterns

### **Security Analytics**
- Simulate security pen-testing scenarios
- Generate comprehensive security test traces
- Analyze vulnerability patterns and trends

### **Cost Optimization**
- Track LLM usage and costs across projects
- Identify cost optimization opportunities
- Monitor budget thresholds and alerts

### **Business Intelligence**
- Create executive dashboards
- Generate compliance reports
- Analyze AI adoption metrics

## Prerequisites

- Azure subscription with appropriate permissions
- Azure Data Explorer cluster (deployed via terraform)
- Azure AI Foundry project with deployed models
- Python environment with required packages:
  - `azure-kusto-data>=4.4.0` - Azure Data Explorer client
  - `azure-kusto-ingest>=4.4.0` - Data ingestion client
  - Other dependencies listed in `pyproject.toml`

## Key Features

- **Comprehensive Tracing** - Every AI interaction captured with rich metadata  
- **Real-time Analytics** - KQL queries for immediate insights  
- **Cost Tracking** - Detailed token usage and cost analysis  
- **Security Monitoring** - Pen-testing simulation and vulnerability tracking  
- **Scalable Architecture** - Enterprise-ready data ingestion and storage  

## Next Steps

1. Deploy ADX infrastructure using terraform scripts
2. Set up database schema using KQL scripts
3. Run tracing notebooks to generate sample data
4. Create custom dashboards and alerts
5. Integrate with your existing monitoring stack

For detailed instructions, see the README files in each subfolder.
