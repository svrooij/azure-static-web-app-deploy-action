param (
  
  [Parameter(Mandatory = $true, HelpMessage = "Path to files to deploy")]
  [string]$AppLocation,
  [Parameter(Mandatory = $true, HelpMessage = "Static web app environment")]
  [string]$Environment,

  [Parameter(Mandatory = $false, HelpMessage = "Path to API files to deploy")]
  [string]$ApiLocation = $null,
  [Parameter(Mandatory = $false, HelpMessage = "Directory that contains the staticwebapp.config.json file")]
  [string]$ConfigDirectory = $null
)

BEGIN {
  $ErrorActionPreference = "Stop"
  $PSDefaultParameterValues["*:ErrorAction"] = "Stop"

  if (-not (Get-Command swa -ErrorAction SilentlyContinue)) {
    Write-Host "::error title=SWA CLI not found::Please ensure SWA CLI is installed."
    exit 1
  }

  if (-not (Test-Path $AppLocation)) {
    Write-Host "::error title=App Location not found::The specified app location '$AppLocation' does not exist."
    exit 1
  }

  if ($ApiLocation -and -not (Test-Path $ApiLocation)) {
    Write-Host "::error title=API Location not found::The specified API location '$ApiLocation' does not exist."
    exit 1
  }

  # Build the SWA CLI command parameters
  Write-Host "Starting deployment using SWA CLI..."
  $cliParameters = @{
    # app_location = $AppLocation
    # output_location = $OutputLocation
    env = $Environment
  }

  if ($ApiLocation) {
    $cliParameters["api-location"] = $ApiLocation
  }

  if ($ConfigDirectory) {
    if (-not (Test-Path $ConfigDirectory)) {
      Write-Host "::error title=Config Directory not found::The specified config directory '$ConfigDirectory' does not exist."
      exit 1
    }
    $cliParameters["swa-config-location"] = $ConfigDirectory
  }

  # Convert parameters to a format suitable for the swa command
  $swaCommand = "swa deploy $AppLocation"
  foreach ($key in $cliParameters.Keys) {
    $swaCommand += " --$key $($cliParameters[$key])"
  }

  Write-Host "Command: $swaCommand"
  # Execute the SWA CLI command
  try {
    Invoke-Expression $swaCommand
  } catch {
    Write-Host "::error title=Deployment failed::An error occurred during deployment ❌: $_"
    exit 1
  }
  Write-Host "Deployment completed successfully."
}