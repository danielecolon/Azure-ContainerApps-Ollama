#Author: Daniel Colón
#Date: 11/8/2025
#Title: safe2delete.ps1
#Purpose: Delete resource groups with tag safe2delete

# Login to Azure (if not already logged in)
#az login

# Get all resource groups with the tag 'status=safe2delete'
$resourceGroups = az group list --query "[?tags.status=='safe2delete'].name" -o tsv

# Loop through each resource group and delete it
foreach ($rg in $resourceGroups) {
    Write-Host "Deleting resource group: $rg"
    
    # Uncomment the next line to delete without confirmation
    az group delete --name $rg --yes --no-wait

    # Delete with confirmation prompt
    #az group delete --name $rg
}