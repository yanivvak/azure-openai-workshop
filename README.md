# Azure OpenAI workshop
This repository is a compilation of useful Azure OpenAI Service resources and code samples to help you get started and accelerate your technology adoption journey.

## What is GPT?
GPT (Generative Pre-trained Transformer) is a Large Language Model (LLM) developed by OpenAI. It is a deep learning model based on the Transformer architecture. For more information, refer to [OpenAI](openai.com).

## Get started
### 1. Prerequisites

- **Azure Account** - If you're new to Azure, get an Azure account for [free](https://aka.ms/free) and you'll get some free Azure credits to get started.
- **Azure subscription with access enabled for the Azure OpenAI Service** - For more details, see the [Azure OpenAI Service documentation on how to get access](https://learn.microsoft.com/azure/ai-services/openai/overview#how-do-i-get-access-to-azure-openai). 
- **Azure Open AI resource** - For these samples, you'll need to deploy models like GPT-3.5 Turbo, GPT 4, DALL-E, and Whisper. See the Azure OpenAI Service documentation for more details on [deploying models](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource?pivots=web-portal) and [model availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models).

If you prefer to run these samples locally, you'll need to install and configure the following:

- [Visual Studio Code](https://code.visualstudio.com/Download)
- Python
  - [Python 3.8+](https://www.python.org/downloads/)
  - [Jupyter Notebook 6.5.2](https://jupyter.org/install)
  - [Python VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

### 2. update credentials
To use sample codes in this repo, we suggest you setup .env file where you store key informations for Azure services. See [.env.sample](./.env.sample) file for example.


### Setup
0. Clone the repo
```bash
git clone https://github.com/yanivvak/azure-openai-workshop.git
```

1. set up a virtual environment (optional)
```bash
python3 -m venv aoai-ws
source aoai-env/bin/activate
```
To deactivate :
```bash
deactivate
```
> More information about virtual environments can be found [here](https://docs.python.org/3/tutorial/venv.html)

2. install requirements
```bash
pip install -r requirements.txt
```
