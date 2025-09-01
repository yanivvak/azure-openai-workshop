# ADX Schema Setup Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: Azure CLI Script Execution Fails

**Symptoms**: 
- `ScriptExecutionFailed` error during automated deployment
- `Syntax error: SYN0001` messages

**Solution**: Use manual setup via ADX Web UI
1. Open the ADX Web UI (URL provided in deployment output)
2. Copy and paste the complete contents of `complete-schema-setup.kql`
3. Run the entire script at once (don't run line by line)

### Issue 2: "Table does not exist" Error

**Symptoms**: 
- Data connection creation fails
- Mappings reference non-existent tables

**Solution**: 
The `complete-schema-setup.kql` file creates tables first, then mappings. This error occurs when:
1. Tables weren't created successfully 
2. Running commands out of order

**Fix**: Run the complete schema script which creates tables before mappings.

### Issue 3: Permission Denied

**Symptoms**: 
- Cannot create tables or functions
- Access denied errors

**Solution**: 
1. Ensure you're logged into Azure: `az login`
2. Check you have proper permissions on the ADX cluster
3. You need at least `Database User` role

### Issue 4: Connection Issues

**Symptoms**: 
- Cannot connect to ADX cluster
- Timeout errors

**Solution**: 
1. Verify cluster is running: Check Azure Portal
2. Check cluster URL is correct
3. Try accessing via different browser/incognito mode

## Manual Setup Process

If automated setup fails, follow these steps:

### Step 1: Open ADX Web UI
```
Use URL from .env file: ADX_WEB_UI
Or: https://dataexplorer.azure.com/clusters/[cluster-name]/databases/TracingDB
```

### Step 2: Run Complete Schema
1. Clear the query window
2. Copy **all** contents from `complete-schema-setup.kql`
3. Paste into query window
4. Click "Run" to execute everything at once

### Step 3: Verify Success
```kql
.show tables
```
Should show: `OTelTraces`, `SecurityTraces`, `LLMInteractions`

## Testing Commands

### Basic Connection Test
```kql
print "ADX Connection Test Successful"
```

### Verify Database
```kql
print database_name = current_database()
```
Should return: `TracingDB`

### Check Tables
```kql
.show tables
```

### Test Functions
```kql
// Should show 7 functions
.show functions
```

## Alternative: Step-by-Step Setup

If running the complete script fails, try individual files:

1. **Tables**: Use `step1-create-otel-table.kql`, `step2-create-security-table.kql`, `step3-create-llm-table.kql`
2. **Mappings**: Use `step4-create-mappings.kql`
3. **Test**: Use `test-tables-exist.kql`

## Known Azure CLI Limitations

The Azure CLI `kusto` commands are experimental and may fail. This is a known issue, not a problem with your setup. The manual Web UI approach is more reliable.

## Getting Help

If issues persist:
1. Check cluster status in Azure Portal
2. Verify Azure subscription permissions
3. Try the manual setup process above
4. Use individual step files if the complete script fails
