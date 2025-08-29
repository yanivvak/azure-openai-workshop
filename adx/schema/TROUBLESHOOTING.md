# ADX Error Troubleshooting Guide

## 🚨 Current Error
`Unknown error occurred. CID: UKN61546fcf-2a39-4dd6-b3db-c5241681d3fc`

This error typically occurs when:
1. Running too many commands at once
2. Syntax issues in KQL commands
3. Permission issues
4. Database connection problems

## 🔧 Step-by-Step Resolution

### Method 1: Run Commands One at a Time

1. **Start with Step 1**: Copy and paste contents of `step1-create-otel-table.kql`
2. **Wait for success** before proceeding
3. **Continue with Step 2**: Use `step2-create-security-table.kql`
4. **Continue with Step 3**: Use `step3-create-llm-table.kql`
5. **Test**: Run `test-tables-exist.kql` to verify
6. **Add mappings**: Use `step4-create-mappings.kql`

### Method 2: Basic Connection Test

First, test if your connection is working:

```kql
print "Hello ADX"
```

If this fails, there's a connection issue.

### Method 3: Check Database Context

Make sure you're connected to the right database:

```kql
print database_name = current_database()
```

Should return: `TracingDB`

### Method 4: Check Permissions

Test if you have table creation permissions:

```kql
.show principal access
```

## 🔍 Common Issues and Solutions

### Issue 1: Not Connected to Correct Database
**Solution**: Make sure you're connected to `TracingDB` database in your cluster

### Issue 2: Permission Denied
**Solution**: You need `Database Admin` or `Database User` permissions

### Issue 3: Syntax Errors
**Solution**: Use the step-by-step files which contain single commands

### Issue 4: Browser/Connection Issues
**Solutions**:
- Refresh the ADX Web UI page
- Clear browser cache
- Try in incognito/private mode
- Use a different browser

## 🎯 Minimal Test Commands

If everything else fails, try these ultra-simple commands one at a time:

### Test 1: Basic print
```kql
print "test"
```

### Test 2: Show current database
```kql
print current_database()
```

### Test 3: Create simple table
```kql
.create table TestTable (ID: int, Name: string)
```

### Test 4: Drop test table
```kql
.drop table TestTable
```

## 📞 If Still Having Issues

1. **Check Azure Portal**: Go to your ADX cluster in Azure Portal and check if it's running
2. **Check cluster status**: Look for any maintenance or issues
3. **Try Azure CLI**: Use `az kusto` commands as alternative
4. **Contact Azure Support**: Use the error CID for reference

## 🔄 Alternative: Use Azure CLI

If the Web UI continues to fail, try using Azure CLI:

```bash
# List tables
az kusto query --cluster-name "https://adx-viytdz.eastus.kusto.windows.net" \
               --database-name "TracingDB" \
               --query ".show tables"

# Create table via CLI
az kusto query --cluster-name "https://adx-viytdz.eastus.kusto.windows.net" \
               --database-name "TracingDB" \
               --query-file "step1-create-otel-table.kql"
```
