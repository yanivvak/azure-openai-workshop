# Azure OpenAI Workshop - UV Project Setup

This repository now uses [uv](https://github.com/astral-sh/uv) for modern Python dependency management.

## Quick Start

1. **Install uv** (if not already installed):
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **Install dependencies**:
   ```bash
   uv sync
   ```

3. **Activate the virtual environment**:
   ```bash
   source .venv/bin/activate
   ```

4. **Run Jupyter**:
   ```bash
   uv run jupyter lab
   ```

## Available Dependency Groups

### Base Dependencies
The core dependencies are automatically installed with `uv sync`:
- `openai` - OpenAI Python SDK
- `azure-ai-projects` - Azure AI Projects SDK
- `azure-ai-inference` - Azure AI Inference SDK
- `azure-identity` - Azure authentication
- `pandas`, `numpy` - Data manipulation
- `matplotlib`, `pillow` - Visualization
- `jupyter` - Notebook environment

### Optional Dependencies

Install additional dependency groups as needed:

#### Development Tools
```bash
uv sync --group dev
```
Includes: pytest, black, isort, flake8, mypy

#### Tracing & Observability (Workshop 2)
```bash
uv sync --group tracing
```
Includes: OpenTelemetry packages, Azure Monitor

#### Agent Frameworks (Workshop 3)
```bash
uv sync --group agents
```
Includes: Semantic Kernel, AutoGen

## Running Commands

### Using uv run
You can run commands directly without activating the environment:

```bash
# Run Jupyter
uv run jupyter lab

# Run Python scripts
uv run python script.py

# Run development tools
uv run black .
uv run pytest
```

### Traditional Virtual Environment
If you prefer the traditional approach:

```bash
# Activate the environment
source .venv/bin/activate

# Now run commands normally
jupyter lab
python script.py
```

## Adding New Dependencies

Add new dependencies to `pyproject.toml`:

```bash
# Add a new package
uv add package-name

# Add a development dependency
uv add --group dev package-name

# Add to a specific group
uv add --group tracing package-name
```

## Environment Management

- **Python version**: The project uses Python 3.12+
- **Virtual environment**: Located in `.venv/`
- **Lock file**: `uv.lock` contains exact versions for reproducibility

## Migration from pip

If you were previously using the `workshop/` virtual environment or `legacy/requirements.txt`, you can now remove those and use this uv-managed environment instead.

The uv environment includes all dependencies with up-to-date versions and better dependency resolution.
