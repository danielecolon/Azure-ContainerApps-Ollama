#Author: Daniel Colón
#Date: 11/16/2025
#Title: st.ps1
#Purpose: Create Storage account following given name convention

# Resoure Group
#. ".\rg.ps1"

# Storage
az storage account create --name "st$PROJECT$RANDOM" --resource-group $RG --location $L --sku Standard_LRS --kind StorageV2 --query name -o tsv
$ST=$(az storage account show -n "st$PROJECT$RANDOM" --query name -o tsv)
$ST_Id=$(az storage account show -n "st$PROJECT$RANDOM" --query id -o tsv)