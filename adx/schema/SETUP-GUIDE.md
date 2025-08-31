# ADX Schema Setup Guide

This directory contains the database schema and setup scripts for Azure Data Explorer (ADX).

## Files Overview

- `✅ complete-schema-setup.kql` - ✅ Complete schema with tables, mappings, and functions
- `test-connection.kql` - Basic connection test
- `test-tables-exist.kql` - Verify tables are created

## Automated Setup (Recommended)

The schema is automatically deployed when using:

```bash
cd ../terraform
./deploy-adx-✅ complete.sh
```

## Manual Setup

If you need to run the schema manually:

1. Open the ADX Web UI
2. Navigate to your TracingDB database
3. Copy and execute the contents of `✅ complete-schema-setup.kql`
4. Verify with `test-tables-exist.kql`

## Fixed Approach - Run Commands in Steps

### Step 1: Setup Tables and Functions
1. **Clear the query window** in ADX Web UI
2. **Copy and paste ONLY** the contents from: ✅ `✅ complete-schema-setup.kql`
3. **Click Run** to execute all setup commands
4. **Wait for completion** - should show success messages

### Step 2: Verify Setup (Optional)
1. **Clear the query window** again
2. **Copy and paste** the contents from: `test-tables-exist.kql`
3. **Run each query individually** (don't run all at once)

## Quick Test
After setup, run this simple test:
```kql
.show tables
```

Should show: `OTelTraces`, `SecurityTraces`, `LLMInteractions`

## Expected Tables Created:
- `OTelTraces` - OpenTelemetry tracing data
- `SecurityTraces` - Security pen-testing results  
- `LLMInteractions` - LLM API usage and costs
