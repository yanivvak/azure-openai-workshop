# Azure OpenAI Workshop

A comprehensive workshop for building AI applications with Azure AI Foundry. This repository provides hands-on exercises covering model deployment, tracing & observability, and agent-based applications.

## 🚀 Quick Start

### Prerequisites

- **Azure Account** - Get an Azure account for [free](https://aka.ms/free) with some free Azure credits to get started
- **Azure subscription with access enabled for the Azure OpenAI Service** - See the [Azure OpenAI Service documentation](https://learn.microsoft.com/azure/ai-services/openai/overview#how-do-i-get-access-to-azure-openai) for access details
- **Python 3.12+** - Required for the workshop environment

## 📋 Complete Getting Started Flow

### Step 1: Clone the Repository

```bash
git clone https://github.com/yanivvak/azure-openai-workshop.git
cd azure-openai-workshop
```

### Step 2: Set Up Python Environment

**Option A: Using uv (Recommended)**

1. **Install uv** (modern Python dependency manager):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Install all dependencies**:
   ```bash
   uv sync
   ```

3. **Validate installation**:
   ```bash
   uv run python validate_setup.py
   ```

**Option B: Traditional Virtual Environment**

1. **Create virtual environment**:
   ```bash
   python -m venv workshop
   ```

2. **Activate environment**:
   ```bash
   # On macOS/Linux:
   source workshop/bin/activate
   
   # On Windows:
   workshop\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r legacy/requirements.txt
   ```

### Step 3: Deploy Azure Infrastructure

Choose your preferred Infrastructure as Code tool:

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

The deployment creates:
- Azure AI Foundry resource
- AI Foundry project
- GPT-4o model deployment
- Required permissions and security settings

### Step 4: Configure Environment Variables

After successful infrastructure deployment, configure your environment variables:

1. **Copy the environment template**:
   ```bash
   cp .env.example .env
   ```

2. **Update the minimum required variables** in `.env` file using the deployment outputs:

   **Required Variables:**
   ```bash
   # From deployment output: aiFoundryEndpoint
   AZURE_OPENAI_ENDPOINT=https://your-foundry-resource.cognitiveservices.azure.com/
   
   # From deployment output: modelDeploymentName  
   AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4o
   
   # API version for Azure OpenAI
   AZURE_OPENAI_API_VERSION=2024-10-21
   ```

3. **Choose authentication method**:
   
   **Option A: Entra ID Authentication (Recommended)**
   - No additional configuration needed
   - Uses your Azure CLI login (`az login`)
   - Most secure for development
   
   **Option B: API Key Authentication**
   - Get API key from Azure Portal → Your AI Foundry resource → Keys and Endpoint
   - Add to `.env` file:
   ```bash
   AZURE_OPENAI_API_KEY=your-api-key-here
   ```

4. **Optional: Add additional variables** for advanced features:
   ```bash
   # For AI Foundry SDK features
   PROJECT_ENDPOINT=https://your-foundry-resource.services.ai.azure.com/api/projects/your-project-name
   AZURE_AI_FOUNDRY_RESOURCE_NAME=your-foundry-resource
   AZURE_AI_FOUNDRY_PROJECT_NAME=your-project-name
   AZURE_RESOURCE_GROUP_NAME=your-resource-group
   ```
   - **Alternative**: Use API key authentication (set `AZURE_AI_FOUNDRY_API_KEY`)

### Step 5: Start the Workshop

1. **Launch Jupyter Lab**:
   ```bash
   # With uv:
   uv run jupyter lab
   
   # With traditional environment:
   jupyter lab
   ```

2. **Begin with the first notebook**:
   - Open `01-deploy-first-model.ipynb`
   - Follow the step-by-step instructions

## 📚 Workshop Structure

| Notebook | Topic | Description |
|----------|-------|-------------|
| `01-deploy-first-model.ipynb` | **Model Deployment** | Deploy and test your first Azure OpenAI model |
| `02-tracing.ipynb` | **Tracing & Observability** | Implement monitoring and tracing for AI applications |
| `03-agents.ipynb` | **Agent Applications** | Build intelligent agent-based applications |

## 🛠️ Validation & Troubleshooting

### Validate Your Setup

Run the validation script to ensure everything is working:

```bash
uv run python validate_setup.py
```

This checks:
- ✅ All required Python packages
- ✅ Azure SDK integration
- ✅ Python environment configuration

### Common Issues

| Issue | Solution |
|-------|----------|
| **Authentication errors** | Run `az login` and verify subscription access |
| **Module import errors** | Run `uv sync` or reinstall dependencies |
| **Environment variable errors** | Ensure minimum required variables are set: `AZURE_OPENAI_ENDPOINT`, `AZURE_OPENAI_DEPLOYMENT_NAME`, `AZURE_OPENAI_API_VERSION` |
| **API key issues** | Get API key from Azure Portal → Your AI Foundry resource → Keys and Endpoint |
| **Quota exceeded** | Request quota increase or change Azure region |
| **Model deployment fails** | Ensure S0 SKU and region supports GPT-4o |
| **Bicep deployment validation errors** | Ensure using latest Bicep version (`az bicep upgrade`) |

### Quick Environment Setup Check

If you're getting authentication or connection errors, verify these minimum environment variables are set:

```bash
# Check current values
echo "AZURE_OPENAI_ENDPOINT: $AZURE_OPENAI_ENDPOINT"
echo "AZURE_OPENAI_DEPLOYMENT_NAME: $AZURE_OPENAI_DEPLOYMENT_NAME" 
echo "AZURE_OPENAI_API_VERSION: $AZURE_OPENAI_API_VERSION"

# If using API key authentication
echo "AZURE_OPENAI_API_KEY: ${AZURE_OPENAI_API_KEY:0:10}..." # Shows first 10 chars only
```

## 🔧 Development & Customization

### Adding Dependencies

```bash
# Add a new package
uv add package-name

# Add development tools
uv add --group dev package-name
```

### Included Dependencies

All workshop dependencies are included by default when you run `uv sync`:

- **Core Azure AI**: `azure-ai-projects[agents]`, `azure-ai-inference`, `azure-identity`
- **OpenAI SDK**: `openai` with Azure OpenAI support
- **Tracing & Observability**: `opentelemetry-*`, `azure-monitor-opentelemetry`
- **Data Analysis**: `pandas`, `numpy`, `matplotlib`
- **Jupyter**: `jupyter`, `ipykernel`

### Optional Dependency Groups

- **Development**: `uv sync --group dev` (pytest, black, mypy)

## 📖 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Infrastructure Setup Guide](./infrastructure/README.md)
- [UV Setup Details](./UV_SETUP.md)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
