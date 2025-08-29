# Azure OpenAI Workshop

A comprehensive hands-on workshop for building AI applications with Azure AI Foundry. Learn to deploy models, implement tracing & observability, and create intelligent agent-based applications.

## ⚡ Quick Start (5 Minutes)

**Want to jump straight to enterprise security analytics?**

📖 **[Follow the Quick Start Guide →](QUICK_START.md)**

3 simple commands to deploy Azure Data Explorer and generate 120+ realistic security test scenarios with AI analysis!

## 📚 What You'll Learn

- Deploy and test Azure OpenAI models
- Implement monitoring and tracing for AI applications  
- Build intelligent agent-based applications
- Work with Azure AI Foundry SDK
- **NEW:** Enterprise-scale security analytics with Azure Data Explorer

## 🚀 Prerequisites

Before starting, ensure you have:

- **Azure Account** - [Get free Azure credits](https://aka.ms/free)
- **Azure OpenAI Access** - [Request access](https://learn.microsoft.com/azure/ai-services/openai/overview#how-do-i-get-access-to-azure-openai) to Azure OpenAI Service
- **Azure CLI** - For authentication and infrastructure deployment
- **Python 3.12+** - Required for the workshop environment

### Install Azure CLI

Choose your platform:

| Platform | Command |
|----------|---------|
| **macOS** | `brew install azure-cli` |
| **Windows** | `winget install Microsoft.AzureCLI` |
| **Linux (Ubuntu/Debian)** | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |

For other platforms, see the [Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### Authenticate with Azure

```bash
# Login to Azure
az login

# Verify your subscription
az account show
```

## 🏁 Getting Started

### Step 1: Clone and Setup Environment

```bash
# Clone the repository
git clone https://github.com/yanivvak/azure-openai-workshop.git
cd azure-openai-workshop

# Install uv (modern Python dependency manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Validate installation
uv run python validate_setup.py
```

### Step 2: Deploy Azure Infrastructure

Choose your preferred deployment method:

**Option A: Bicep (Azure-native)**
```bash
cd infrastructure/bicep
./deploy.sh
```

**Option B: Terraform (Multi-cloud)**
```bash
cd infrastructure/terraform
./deploy.sh
```

This deployment creates:
- Azure AI Foundry resource
- AI Foundry project  
- GPT-4.1-mini model deployment
- Required permissions and security settings

### Step 3: Configure Environment

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Update required variables** in `.env` using deployment outputs:
   ```bash
   # From deployment output: aiFoundryEndpoint
   AZURE_OPENAI_ENDPOINT=https://your-foundry-resource.cognitiveservices.azure.com/
   
   # From deployment output: modelDeploymentName  
   AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4.1-mini
   
   # API version
   AZURE_OPENAI_API_VERSION=2024-10-21
   ```

3. **Choose authentication method:**

   **Option A: Entra ID (Recommended)**
   - Uses your `az login` credentials
   - No additional setup required
   
   **Option B: API Key**
   - Get key from Azure Portal → AI Foundry resource → Keys and Endpoint
   - Add to `.env`: `AZURE_OPENAI_API_KEY=your-api-key`

### Step 4: Start the Workshop

Open the first notebook and begin:
```bash
# Launch Jupyter (if using Jupyter)
jupyter lab

# Or work directly in VS Code with the Python extension
```

## 📚 Workshop Notebooks

| Notebook | Topic | Description |
|----------|-------|-------------|
| `01-deploy-first-model.ipynb` | **Model Deployment** | Deploy and test your first Azure OpenAI model |
| `02-foundry-tracing.ipynb` | **Tracing & Observability** | Implement monitoring and tracing for AI applications |
| `03-agent_evaluators.ipynb` | **Agent Evaluation** | Learn to evaluate and test AI agents |
| `04-agents.ipynb` | **Agent Applications** | Build intelligent agent-based applications |
| `05-agents_tracing.ipynb` | **Advanced Tracing** | Advanced tracing techniques for agents |
| `06-fine_tuning.ipynb` | **Fine-tuning** | Custom model fine-tuning with Azure OpenAI |

## 🛠️ Troubleshooting

### Validate Your Setup

```bash
uv run python validate_setup.py
```

This checks all required packages, Azure SDK integration, and environment configuration.

### Common Issues

| Issue | Solution |
|-------|----------|
| **Authentication errors** | Run `az login` and verify with `az account show` |
| **Azure CLI not found** | Install Azure CLI, then run `az login` |
| **Wrong subscription** | Run `az account set --subscription "Your Subscription Name"` |
| **Module import errors** | Run `uv sync` to reinstall dependencies |
| **Environment variable errors** | Ensure required variables are set in `.env` file |
| **API quota exceeded** | Request quota increase or change Azure region |
| **Model deployment fails** | Ensure S0 SKU and region supports GPT-4.1-mini |

### Quick Environment Check

Verify your environment variables:

```bash
echo "Endpoint: $AZURE_OPENAI_ENDPOINT"
echo "Deployment: $AZURE_OPENAI_DEPLOYMENT_NAME" 
echo "API Version: $AZURE_OPENAI_API_VERSION"
```

## 🔧 Advanced Configuration

### Adding Dependencies

```bash
# Add a new package
uv add package-name

# Add development tools  
uv add --group dev package-name
```

### Included Dependencies

The workshop includes all necessary packages:

- **Azure AI**: `azure-ai-projects[agents]`, `azure-ai-inference`, `azure-identity`
- **OpenAI SDK**: `openai` with Azure OpenAI support
- **Observability**: `opentelemetry-*`, `azure-monitor-opentelemetry`
- **Data Analytics**: `azure-kusto-data`, `azure-kusto-ingest` (Azure Data Explorer)
- **Data & Analysis**: `pandas`, `numpy`, `matplotlib`
- **Jupyter**: `jupyter`, `ipykernel`

## 📖 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Infrastructure Setup Guide](./infrastructure/README.md)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and enhancement requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
