# Self-Hosting AI LLM Demo
![alt text](AzureArchitectureDiagram.png)<br />
Instructions used in the **Self-Hosting AI LLM** presentation.<br />
You will deploy an AI model using **Azure Container Apps** and supporting scripts included in this repository. 

## Prerequisites
- An Azure subscription
- Azure CLI
  - Run az version to find the version and dependent libraries that are installed. To upgrade to the latest version, run az upgrade
- Docker Desktop

## Instructions
Instructions under development branch.
They are not fully tested.
Once they are completed they will be posted here.

## Open a PowerShell Terminal

## Clone the Repository
git clone https://github.com/danielecolon/Azure-ContainerApps-Ollama.git

## Navigate into the project directory:
cd Azure-ContainerApps-Ollama
cd demo

## Deploy Azure Container Apps Environment
.\ace.ps1

## Deploy the Ollama Container App
.\aca.ps1

## Deploy the Web UI
.\aca-web-webui.ps1

## Cleanup
Delete the resource group that was created using the Azure Portal or run the following:<br />
.\s2d.ps1