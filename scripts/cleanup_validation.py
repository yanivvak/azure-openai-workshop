#!/usr/bin/env python3
"""
Repository Cleanup Validation Script
Ensures the repository is clean and ready for public distribution
"""

import os
import re
import json
from pathlib import Path

def check_secrets_and_sensitive_data():
    """Check for exposed secrets and sensitive data"""
    
    sensitive_patterns = [
        r'InstrumentationKey=[\w-]+',
        r'IngestionEndpoint=https://[\w.-]+',
        r'ApplicationId=[\w-]+',
        r'foundry-[a-z0-9]+',  # Specific resource names
        r'rg-foundry-[a-z0-9]+',  # Resource group names
        r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}',  # UUIDs/GUIDs
    ]
    
    # Files to check
    files_to_check = [
        '.env',
        '.env.example', 
        'README.md',
        '*.ipynb',
        'infrastructure/**/*.bicep',
        'infrastructure/**/*.tf',
    ]
    
    issues = []
    
    for pattern in files_to_check:
        for file_path in Path('.').glob(pattern):
            if file_path.is_file():
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                    for i, line in enumerate(content.split('\n'), 1):
                        for sensitive_pattern in sensitive_patterns:
                            if re.search(sensitive_pattern, line):
                                # Skip if it's a placeholder or comment
                                if any(placeholder in line.lower() for placeholder in 
                                      ['your-', 'placeholder', 'example', 'sample', '#', '//']):
                                    continue
                                    
                                issues.append(f"{file_path}:{i} - Potential sensitive data: {line.strip()[:100]}")
                                
                except Exception as e:
                    print(f"Warning: Could not check {file_path}: {e}")
    
    return issues

def check_orphaned_files():
    """Check for orphaned or unnecessary files"""
    
    unnecessary_files = [
        'test_environment.md',
        'prerequisites/',
        '.env.local',
        '.env.production',
        'terraform.tfstate',
        'terraform.tfstate.backup',
    ]
    
    found_files = []
    for file_pattern in unnecessary_files:
        for file_path in Path('.').glob(file_pattern):
            if file_path.exists():
                found_files.append(str(file_path))
    
    return found_files

def check_notebook_outputs():
    """Check if notebooks have outputs that should be cleared"""
    
    notebooks_with_outputs = []
    
    for notebook_path in Path('.').glob('*.ipynb'):
        try:
            with open(notebook_path, 'r', encoding='utf-8') as f:
                notebook_data = json.load(f)
            
            for i, cell in enumerate(notebook_data.get('cells', [])):
                if cell.get('outputs') or cell.get('execution_count'):
                    notebooks_with_outputs.append(f"{notebook_path} - Cell {i}")
                    break
                    
        except Exception as e:
            print(f"Warning: Could not check notebook {notebook_path}: {e}")
    
    return notebooks_with_outputs

def main():
    """Run all cleanup validation checks"""
    
    print(" Repository Cleanup Validation")
    print("=" * 40)
    
    # Check for secrets
    print("\n Checking for exposed secrets...")
    secrets_issues = check_secrets_and_sensitive_data()
    if secrets_issues:
        print(" Found potential secret exposures:")
        for issue in secrets_issues:
            print(f"   {issue}")
    else:
        print(" No exposed secrets found")
    
    # Check for orphaned files
    print("\n  Checking for orphaned files...")
    orphaned_files = check_orphaned_files()
    if orphaned_files:
        print(" Found orphaned files:")
        for file_path in orphaned_files:
            print(f"   {file_path}")
    else:
        print(" No orphaned files found")
    
    # Check notebook outputs
    print("\n Checking notebook outputs...")
    notebooks_with_outputs = check_notebook_outputs()
    if notebooks_with_outputs:
        print("  Found notebooks with outputs (consider clearing):")
        for notebook in notebooks_with_outputs:
            print(f"   {notebook}")
    else:
        print(" All notebooks have clean outputs")
    
    # Summary
    total_issues = len(secrets_issues) + len(orphaned_files)
    
    print(f"\n Summary:")
    print(f"   Secrets issues: {len(secrets_issues)}")
    print(f"   Orphaned files: {len(orphaned_files)}")
    print(f"   Notebooks with outputs: {len(notebooks_with_outputs)}")
    
    if total_issues == 0: ✅ print("\n Repository is clean and ready for distribution!")
        return 0
    else:
        print(f"\n  Found {total_issues} issues that should be addressed")
        return 1

if __name__ == "__main__":
    exit(main())
