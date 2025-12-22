param (
    [string]$RANDOM
)

$startTime = Get-Date

# Make sure Random parameter is provided
if (-not $RANDOM) {
    Write-Host "No RANDOM argument was passed to the script."
    exit 1
}

# Make sure Docker Desktop is running
function Test-DockerRunning {
    try {
        # Attempt to run a basic docker command, redirecting stderr to stdout
        # and capturing the output.
        $dockerOutput = docker ps 2>&1 | Out-String

        # If the output contains an error message indicating the daemon is not running,
        # then Docker is not running.
        if ($dockerOutput -match "Cannot connect to the Docker daemon" -or $dockerOutput -match "error during connect"  -or $dockerOutput -match "failed to connect") {
            return $false
        }
        # If no such error is found, and the command executed successfully (i.e., no
        # command not found errors), then Docker is likely running.
        return $true
    } catch {
        # Catch any exceptions, such as 'docker' command not found,
        # which also indicates Docker is not running or not installed.
        return $false
    }
}

if (Test-DockerRunning) {
    Write-Host "Docker is running."
} else {
    Write-Host "Docker is NOT running or not installed."
    Exit
}

$IMAGE="alpine-ollama"
$VERSION="012.10"

#$RANDOM parameter passed from previous script
$PROJECT="ollama"
$ACA=$IMAGE
$RG="rg-$PROJECT-$RANDOM"
$ACR="acr$PROJECT$RANDOM"
$CAE="cae$PROJECT$RANDOM"
$ID="idacrpull$RANDOM"
$TARGETPORT=11434

# Change to alpine-ollama directory
Set-Location -Path ".\alpine-ollama"

# Build Image
docker build -t "${ACR}.azurecr.io/${IMAGE}:${VERSION}" .

# Upload Image to ACR
az acr login -n $ACR
docker push "${ACR}.azurecr.io/${IMAGE}:${VERSION}"

# Change to back to demo directory
Set-Location -Path ".."

# Create Container App
az containerapp create -n $ACA -g $RG --environment $CAE --ingress external --target-port $TARGETPORT --min-replicas 1 --max-replicas 2 --cpu 4 --memory 8 --user-assigned "${ID}" --image "${ACR}.azurecr.io/${IMAGE}:${VERSION}" --registry-server "$ACR.azurecr.io"

# Add Mount Drive
# https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts-azure-files?tabs=bash
# Note:  Install-Module -Name powershell-yaml -Force
az containerapp show --name $ACA --resource-group $RG --output yaml > "$ACA.yaml"

# Show Duration 
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Elapsed Time: $($duration.Hours) hours, $($duration.Minutes) minutes, $($duration.Seconds) seconds, $($duration.Milliseconds) milliseconds"

# Edit yaml file
Write-Host ""
Write-Host ""
Write-Host "Edit ${ACA}.yaml"
Write-Host "For Help see: https://learn.microsoft.com/en-us/azure/container-apps/storage-mounts-azure-files?tabs=bash"

$lines = @("
# Insert the following under 'name: alpine-ollama' in the containers section
      volumeMounts:
      - volumeName: models
        mountPath: /models

#Replace 'volumes: null' with the following         
    volumes:
    - name: models
      storageName: caest${PROJECT}${RANDOM}
      storageType: AzureFile

")
$lines | Write-Host

Write-Host "Don't forget to save after editing ${ACA}.yaml"
Write-Host "1. Run the following command"
Write-Host "az containerapp update --name $ACA --resource-group $RG --yaml ${ACA}.yaml"
Write-Host "2. Run the following command to setup open-webui container app"
Write-Host ".\aca_open-webui.ps1 -RANDOM $RANDOM"

#az containerapp update --name $ACA --resource-group $RG --yaml "$ACA.yaml"