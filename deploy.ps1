param (
  
  [Parameter(Mandatory = $true, HelpMessage = "Path to files to deploy")]
  [string]$AppLocation,
  [Parameter(Mandatory = $true, HelpMessage = "Static web app environment")]
  [string]$Environment,

  [Parameter(Mandatory = $false, HelpMessage = "Path to API files to deploy")]
  [string]$ApiLocation = $null,
  [Parameter(Mandatory = $false, HelpMessage = "Directory that contains the staticwebapp.config.json file")]
  [string]$ConfigDirectory = $null,
  [Parameter(Mandatory = $false, HelpMessage = "If the action is running in debug mode")]
  [bool]$IsDebug = $false
)

BEGIN {
  $ErrorActionPreference = "Stop"
  $PSDefaultParameterValues["*:ErrorAction"] = "Stop"

  if (-not (Test-Path $AppLocation)) {
    Write-Host "::error title=App Location not found::The specified app location '$AppLocation' does not exist."
    exit 1
  }

  if ($ApiLocation -and -not (Test-Path $ApiLocation)) {
    Write-Host "::error title=API Location not found::The specified API location '$ApiLocation' does not exist."
    exit 1
  }

  if (-not (Get-Command swa -ErrorAction SilentlyContinue)) {
    Write-Host "📃 Installing SWA CLI @azure/static-web-apps-cli@2.0.6..."
    npm install -g @azure/static-web-apps-cli@2.0.6
  }

  if (-not (Get-Command swa -ErrorAction SilentlyContinue)) {
    Write-Host "::error title=SWA CLI not found::Static web apps CLI could not be installed."
    exit 1
  }

  # Build the SWA CLI command parameters
  Write-Host "✅ Creating SWA CLI command parameters..."
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

  Write-Host "🧑‍💻 Complete command: $swaCommand"
  # Execute the SWA CLI command
  try {
    # capture the output of the command, and extract the url from this output
    # - Preparing deployment. Please wait...
    # ✔ Project deployed to https://jolly-coast-025d49603.6.azurestaticapps.net 🚀
    Write-Host "🚀 Deploying static web app..."
    
    $output = Invoke-Expression $swaCommand 2>&1
    if ($IsDebug) {
      Write-Host "📜 Command output -----------------------------`n: $output`n📜 Command output end--------------------------"
    }
    if ($output -match "✔ Project deployed to (https?://[^\s]+)") {
      $url = $matches[1]
      Write-Host "✅ Deployment URL: $url"
      Write-Host "::set-output name=deployment-url::$url"
    } else {
      Write-Host "::error title=Deployment failed::Could not extract deployment URL from output."
      exit 100
    }
  } catch {
    Write-Host "::error title=Deployment failed::An error occurred during deployment ❌: $_"
    exit 5
  }
}