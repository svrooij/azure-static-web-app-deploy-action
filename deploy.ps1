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
    Invoke-Expression "npm install -g @azure/static-web-apps-cli@2.0.6"
  }

  if (-not (Get-Command swa -ErrorAction SilentlyContinue)) {
    Write-Host "::error title=SWA CLI not found::Static web apps CLI could not be installed."
    exit 1
  }

  # Build the SWA CLI command parameters
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

  # Execute the SWA CLI command
  try {
    # capture the output of the command, and extract the url from this output
    # - Preparing deployment. Please wait...
    # ✔ Project deployed to https://fake-name-02abcdef.6.azurestaticapps.net 🚀
    Write-Host "🚀 Starting deployment in 3..2..1.."
    Write-Host "🧑‍💻 Executing: $swaCommand"
    
    # This should execute the command and capture the swaOutput in $output variable
    Invoke-Expression $swaCommand | Tee-Object -Variable swaOutput
    
    if ($swaOutput -match "Project deployed to (https?://[^\s]+)") {
      $url = $matches[1]
      Write-Host "✅ Deployment URL: $url"
      Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_url=$url"
      Write-Host "::set-output name=deployment-url::$url"
      Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value "## Static web app deployment`n`n✅ Deployment URL: [$url]($url)`n"
    } else {
      try {
        $info = Invoke-RestMethod -Uri "https://content-am2.infrastructure.6.azurestaticapps.net/api/upload/validateapitoken?apiVersion=v1&deploymentCorrelationId=$(New-Guid)" `
          -Method Post -ErrorAction SilentlyContinue `
          -UserAgent "staticsites-swacli-client" `
          -ContentType "application/json; charset=utf-8" `
          -Headers @{
            Authorization = "token $env:SWA_CLI_DEPLOYMENT_TOKEN"
          }
        $url = $info.response.siteUrl
        Write-Host "✅ Deployment URL from api: $url"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_url=$url"
      } catch {
        Write-Host "❔ Unable to get deployment URL from undocumented API. $_"
      }
    }
    Write-Host "🎉 Deployment completed successfully! 🎉"
    exit 0
  } catch {
    Write-Host "::error title=Deployment failed::An error occurred during deployment ❌: $_"
    exit 5
  }
}