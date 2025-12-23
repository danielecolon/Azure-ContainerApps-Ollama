#Author: Daniel Colón
#Date: 11/9/2025
#Title: rg.ps1
#Purpose: Create Resource Group following given name convention

# Variables
#$RANDOM=$(Get-Random).ToString().Substring(0,5)
param(
    [string]$RANDOM=$(Get-Date -Format "HHmm"),
    [string]$PROJECT="default",
    [string]$RG="rg-$PROJECT-$RANDOM",
    [string]$L="southcentralus",
    [string]$ENV="POC",
    [string]$CREATEDATE=$(get-Date -Format "yyyymmdd"),
    [string]$OWNER="Owner Name goes here"  
)

# Sanitize Params
$RANDOM=$RANDOM.ToLower()
$PROJECT=$PROJECT.ToLower()
$RG=$RG.ToLower()

# Resource Group
az group create --name $RG --location $L --tags env=$ENV createdate=$CREATEDATE  status='safe2delete' owner="$OWNER" --query "name" -o tsv