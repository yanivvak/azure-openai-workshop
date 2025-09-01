# ADX Schema Setup Guide

This directory contains the database schema and setup scripts for Azure Data Explorer (ADX).

## Files Overview

- `complete-schema-setup.kql` - ✅ Complete schema with tables, mappings, and functions
- `test-connection.kql` - Basic connection test
- `test-tables-exist.kql` - Verify tables are created

## Automated Setup (Recommended)

The schema is automatically deployed when using:

```bash
cd ../terraform
./deploy-adx-complete.sh
```

## Manual Setup

If the automated setup fails or you need to run the schema manually:

### Step 1: Open ADX Web UI
1. Use the URL from deployment output: `ADX_WEB_UI` in `.env` file
2. Or navigate to: `https://dataexplorer.azure.com/clusters/[your-cluster]/databases/TracingDB`

### Step 2: Run Schema Script
1. **Clear the query window** in ADX Web UI
2. **Copy and paste ALL** contents from: `complete-schema-setup.kql`
3. **Click Run** to execute all setup commands at once
4. **Wait for completion** - should show success messages

### Step 3: Verify Setup
Run this simple test:
```kql
.show tables
```

Should show: `OTelTraces`, `SecurityTraces`, `LLMInteractions`

## Expected Results

After successful setup, you should have:

### Tables Created:
- `OTelTraces` - OpenTelemetry tracing data
- `SecurityTraces` - Security pen-testing results  
- `LLMInteractions` - LLM API usage and costs

### JSON Mappings Created:
- `OTelTracesMapping` - For OpenTelemetry data ingestion
- `SecurityTracesMapping` - For security test data ingestion
- `LLMInteractionsMapping` - For LLM usage data ingestion

### Functions Created:
- `GetTracesByTimeRange()` - Get traces within time range
- `GetSecurityTestsByType()` - Filter security tests by type
- `GetLLMCostAnalysis()` - Analyze LLM costs and usage
- `GetFailedOperations()` - Find failed operations
- `GetSecurityVulnerabilities()` - Get security vulnerabilities
- `GetSecurityTestMetrics()` - Security testing metrics
- `GetTopVulnerableTargets()` - Most vulnerable targets

## Sample Queries After Setup

```kql
// Test basic functionality
SecurityTraces | take 5

// Use built-in functions
GetSecurityTestMetrics(7)
GetLLMCostAnalysis(30)
```

## Troubleshooting

**Error: "Table does not exist"**
- Ensure tables are created before running queries
- Check that the complete schema script ran successfully

**Error: "Syntax error"**
- Copy the entire contents of `complete-schema-setup.kql`
- Run all commands together (don't run line by line)

**Authentication Issues**
- Ensure you're logged into Azure with proper permissions
- Use `az login` if needed
