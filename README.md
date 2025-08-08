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

1. **Copy the environment template**:
   ```bash
   cp .env.sample .env
   ```

2. **Update the `.env` file** with your Azure resource details from the infrastructure deployment outputs:
   - `AZURE_AI_FOUNDRY_ENDPOINT`
   - `PROJECT_ENDPOINT`
   - `AZURE_AI_FOUNDRY_RESOURCE_NAME`
   - `AZURE_AI_FOUNDRY_PROJECT_NAME`
   - `AZURE_RESOURCE_GROUP_NAME`
   - `AZURE_SUBSCRIPTION_ID`

3. **Configure authentication method**:
   - **Recommended**: Use Entra ID authentication (set `OPENAI_API_TYPE=azure_ad`)
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
| **Quota exceeded** | Request quota increase or change Azure region |
| **Model deployment fails** | Ensure S0 SKU and region supports GPT-4o |

## 🔧 Development & Customization

### Adding Dependencies

```bash
# Add a new package
uv add package-name

# Add development tools
uv add --group dev package-name

# Add tracing packages
uv add --group tracing package-name
```

### Optional Dependency Groups

- **Development**: `uv sync --group dev` (pytest, black, mypy)
- **Tracing**: `uv sync --group tracing` (OpenTelemetry, Azure Monitor)
- **Agents**: `uv sync --group agents` (Semantic Kernel, AutoGen)

## 📖 Additional Resources

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Infrastructure Setup Guide](./infrastructure/README.md)
- [UV Setup Details](./UV_SETUP.md)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!
