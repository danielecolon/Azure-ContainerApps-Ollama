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

$IMAGE="open-webui"
$VERSION="v0.6.36"

#$RANDOM parameter passed from previous script
$PROJECT="ollama"
$ACA=$IMAGE
$RG="rg-$PROJECT-$RANDOM"
$ACR="acr$PROJECT$RANDOM"
$CAE="cae$PROJECT$RANDOM"
$ID="idacrpull$RANDOM"
$TARGETPORT=8080

# Change to open-webui directory
Set-Location -Path ".\open-webui"

# Build Image
docker build -t "${ACR}.azurecr.io/${IMAGE}:${VERSION}" .

# Upload Image to ACR
az acr login -n $ACR
docker push "${ACR}.azurecr.io/${IMAGE}:${VERSION}"

# Change to back to demo directory
Set-Location -Path ".."

# Create Container App
az containerapp create -n $ACA -g $RG --environment $CAE --ingress external --target-port $TARGETPORT --min-replicas 1 --max-replicas 2 --cpu 4 --memory 8 --user-assigned "${ID}" --image "${ACR}.azurecr.io/${IMAGE}:${VERSION}" --registry-server "$ACR.azurecr.io"

# Show all variables currently defined
#Get-Variable | Select-Object Name, Value

# Show Duration 
$endTime = Get-Date
$duration = $endTime - $startTime
Write-Host "Elapsed Time: $($duration.Hours) hours, $($duration.Minutes) minutes, $($duration.Seconds) seconds, $($duration.Milliseconds) milliseconds"

# Add Mount Drive
# Current this script only creates the Container App without any mounted storage.
# To add a mounted Azure File Share for open-webui look at how this was done for the # ACA Ollama demo.

Write-Host "You will need to pull down the ollama models to the Ollama server first."
Write-Host "Then you will need to update the Ollama API URL in the open-webui via the admin panel."
Write-Host "Then start exploring open-webui with Ollama models!"