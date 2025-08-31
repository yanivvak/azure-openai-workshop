#!/usr/bin/env python3
"""
Validation script for Azure OpenAI Workshop dependencies.

This script checks that all required packages are installed and can be imported.
Run this after setting up the uv environment to validate your installation.
"""

import sys
from importlib import import_module
from typing import List, Tuple

def check_package(package_name: str, import_name: str = None) -> Tuple[str, bool, str]:
    """Check if a package can be imported."""
    if import_name is None:
        import_name = package_name
    
    try:
        module = import_module(import_name)
        version = getattr(module, "__version__", "unknown")
        return package_name, True, version
    except ImportError as e:
        return package_name, False, str(e)

def main():
    """Main validation function."""
    print(" Azure OpenAI Workshop - Dependency Validation")
    print("=" * 60)
    
    # Core packages to check
    packages_to_check = [
        ("openai", "openai"),
        ("azure-ai-projects", "azure.ai.projects"),
        ("azure-ai-inference", "azure.ai.inference"),
        ("azure-identity", "azure.identity"),
        ("pandas", "pandas"),
        ("numpy", "numpy"),
        ("matplotlib", "matplotlib"),
        ("tiktoken", "tiktoken"),
        ("python-dotenv", "dotenv"),
        ("jupyter", "jupyter"),
        ("ipykernel", "ipykernel"),
    ]
    
    # Optional packages
    optional_packages = [
        ("azure-search-documents", "azure.search.documents"),
        ("azure-storage-blob", "azure.storage.blob"),
        ("markitdown", "markitdown"),
        ("pillow", "PIL"),
    ]
    
    all_good = True
    
    print("\n Core Dependencies:")
    print("-" * 40)
    for package_name, import_name in packages_to_check:
        name, success, version = check_package(package_name, import_name)
        status = "" if success else ""
        print(f"{status} {name:25} {version}")
        if not success: ✅ all_good = False
    
    print("\n Optional Dependencies:")
    print("-" * 40)
    for package_name, import_name in optional_packages:
        name, success, version = check_package(package_name, import_name)
        status = "" if success else " "
        print(f"{status} {name:25} {version}")
    
    print("\n Python Environment:")
    print("-" * 40)
    print(f" Python version: {sys.version}")
    print(f" Python path: {sys.executable}")
    
    # Test basic Azure AI imports
    print("\n Testing Azure AI Integration:")
    print("-" * 40)
    
    try:
        from azure.identity import DefaultAzureCredential
        print(" Azure Identity: DefaultAzureCredential")
    except ImportError as e:
        print(f" Azure Identity: {e}")
        all_good = False
    
    try:
        from azure.ai.projects import AIProjectClient
        print(" Azure AI Projects: AIProjectClient")
    except ImportError as e:
        print(f" Azure AI Projects: {e}")
        all_good = False
    
    try:
        from openai import AzureOpenAI
        print(" OpenAI: AzureOpenAI client")
    except ImportError as e:
        print(f" OpenAI: {e}")
        all_good = False
    
    # Final result
    print("\n" + "=" * 60)
    if all_good: ✅ print(" All core dependencies are working correctly!")
        print(" You're ready to start the Azure OpenAI Workshop!")
        print("\nNext steps:")
        print("1. Set up your .env file with Azure credentials")
        print("2. Run: uv run jupyter lab")
        print("3. Open 01-deploy-first-model.ipynb")
    else: ✅ ❌ ✅ print(" Some dependencies are missing or not working.")
        print("Try running: uv sync")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
