# Azure OpenAI workshop
This repository is a compilation of useful Azure OpenAI Service resources and code samples to help you get started and accelerate your technology adoption journey.

## Get started
### 1. Prerequisites

- **Azure Account** - If you're new to Azure, get an Azure account for [free](https://aka.ms/free) and you'll get some free Azure credits to get started.
- **Azure subscription with access enabled for the Azure OpenAI Service** - For more details, see the [Azure OpenAI Service documentation on how to get access](https://learn.microsoft.com/azure/ai-services/openai/overview#how-do-i-get-access-to-azure-openai). 
- **Azure Open AI resource** - For these samples, you'll need to deploy models like GPT-3.5 Turbo, GPT 4, DALL-E, and Whisper. See the Azure OpenAI Service documentation for more details on [deploying models](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource?pivots=web-portal) and [model availability](https://learn.microsoft.com/azure/ai-services/openai/concepts/models).

### 2. Setup
0. Clone the repo
```bash
git clone https://github.com/yanivvak/azure-openai-workshop.git
```

1. Set up a virtual environment (Prefered)
```bash
python3 -m venv workshop
source workshop-env/bin/activate
```
> To deactivate :
```bash
deactivate
```
> More information about virtual environments can be found [here](https://docs.python.org/3/tutorial/venv.html)

2. install requirements
```bash
pip install -r requirements.txt
```
3. Update credentials

> You can setup .env file where you store key information for Azure services, check [.env.sample](./.env.sample) for example.
   - Update the file with your credentials
   - Save it as .env
