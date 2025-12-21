#Author: Daniel Colón
#Date: 11/8/2025
#Title: aca.ps1
#Purpose: Create ACA with resources that following given name convention

$startTime = Get-Date
# Resoure Group
. .\rg.ps1 -PROJECT "Ollama"

# Required so we can use contanerapp extension
az provider register --namespace Microsoft.App --wait --only-show-errors
az provider show -n Microsoft.App --query "{namespace:namespace registrationState:registrationState}" -o tsv

az provider register --namespace Microsoft.OperationalInsights --wait --only-show-errors
az provider show -n Microsoft.OperationalInsights --query "{namespace:namespace registrationState:registrationState}" -o tsv

az extension add --name containerapp --upgrade --only-show-errors -o none
az extension show --name containerapp --query "{name:name version:version}" -o tsv

# Azure Container Registry
. ".\acr.ps1"

# Managed Identity
az identity create -n "idacrpull$RANDOM" -g $RG --query name -o tsv
$ID = $(az identity show -n "idacrpull$RANDOM" -g $RG --query principalId -o tsv)
start-sleep 30  #Needed to slow down process.  Sometimes failed if new Managed Identity not fully propagated in system

# Assign Managed Identity to ACR PULL Role
$SCOPE = az acr show -n $ACR -g $RG --query id -o tsv
az role assignment create --role "AcrPull" --assignee $ID --scope $SCOPE --query name -o tsv

# Containerapp Environment
az containerapp env create -n "cae$PROJECT$RANDOM" -g $RG -l $L --only-show-errors --query name -o tsv
$CAE = (az containerapp env show -n "cae$PROJECT$RANDOM" -g $RG --query name -o tsv)

# Storage Account
#. ".\st.ps1"
# Storage
az storage account create --name "st$PROJECT$RANDOM" --resource-group $RG --location $L --sku Standard_LRS --kind StorageV2 --query name -o tsv
$ST=$(az storage account show -n "st$PROJECT$RANDOM" --query name -o tsv)

# Storage File Share
$SHARE = "models"
az storage share create -n $SHARE --account-name $ST --quota 100 --only-show-errors --query created -o tsv
$STkey1 = az storage account keys list --account-name $ST -g $RG --query [0].value
start-sleep 30  #Needed to slow down process.  Sometimes unable to set storage on containerapp env if done to quickly
az containerapp env storage set -n $CAE -g $RG --storage-name "caest$PROJECT$RANDOM" --azure-file-account-name $ST --azure-file-account-key "$STkey1" --azure-file-share-name $SHARE --access-mode READWRITE --only-show-errors --query name -o tsv

# Show all variables currently defined
#Get-Variable | Select-Object Name, Value

# Show Duration 
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Elapsed Time: $($duration.Hours) hours, $($duration.Minutes) minutes, $($duration.Seconds) seconds, $($duration.Milliseconds) milliseconds"