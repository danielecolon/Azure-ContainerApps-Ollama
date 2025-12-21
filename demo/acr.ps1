#Author: Daniel Colón
#Date: 11/16/2025
#Title: acr.ps1
#Purpose: Create Container Registry following given name convention

# Resoure Group
#. ".\rg.ps1"

# Azure Container Registry
az acr create --name "acr$PROJECT$RANDOM" --resource-group $RG --location $L --sku Standard --query name -o tsv
$ACR=$(az acr show -n "acr$PROJECT$RANDOM" --query name -o tsv)
$ACR_Id=$(az acr show -n "acr$PROJECT$RANDOM" --query id -o tsv)