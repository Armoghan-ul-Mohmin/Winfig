# ============================
#   Winfig Tools Installer
# ============================

param(
    [switch]$Force = $true
)

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "   WINFIG TOOLS INSTALLER" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray

function Get-PackagesFromJson($path) {
    if (Test-Path $path) {
        try {
            return (Get-Content $path | ConvertFrom-Json)
        } catch {
            Write-Host "ERROR: Could not parse $path as JSON." -ForegroundColor Red
            return @()
        }
    } else {
        Write-Host "ERROR: File not found: $path" -ForegroundColor Red
        return @()
    }
}

# Check for admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Administrator privileges required!" -ForegroundColor Red
    exit 1
}

# Check for winget and choco
$wingetAvailable = (Get-Command winget -ErrorAction SilentlyContinue)
$chocoAvailable = (Get-Command choco -ErrorAction SilentlyContinue)

# Load package lists from JSON files
$wingetJson = Join-Path $PSScriptRoot "Assets/winget-packages.json"
$chocoJson = Join-Path $PSScriptRoot "Assets/choco-packages.json"
$WingetPackages = Get-PackagesFromJson $wingetJson
$ChocoPackages = Get-PackagesFromJson $chocoJson

if ($wingetAvailable) {
    Write-Host "\n--- Installing Winget Packages ---" -ForegroundColor Cyan
    foreach ($wingetId in $WingetPackages) {
        Write-Host "Trying to install $wingetId via winget..." -ForegroundColor White
        try {
            $output = winget install --id $wingetId -e --accept-source-agreements --accept-package-agreements -h 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: $wingetId installed via winget." -ForegroundColor Green
            } elseif ($output -match "already installed") {
                Write-Host "ALREADY INSTALLED: $wingetId" -ForegroundColor Yellow
            } elseif ($output -match "No available upgrade found|No newer package versions are available") {
                Write-Host "ALREADY INSTALLED: $wingetId (up-to-date)" -ForegroundColor Yellow
            } elseif ($output -match "cannot be determined. To upgrade it anyway") {
                Write-Host "ALREADY INSTALLED: $wingetId (unknown version)" -ForegroundColor Yellow
            } else {
                Write-Host "ERROR: Failed to install $wingetId via winget." -ForegroundColor Red
            }
        } catch {
            Write-Host "ERROR: Exception while installing $wingetId via winget." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Winget not available! Skipping winget packages." -ForegroundColor Yellow
}

if ($chocoAvailable) {
    Write-Host "\n--- Installing Choco Packages ---" -ForegroundColor Cyan
    foreach ($chocoId in $ChocoPackages) {
        Write-Host "Trying to install $chocoId via choco..." -ForegroundColor White
        try {
            choco install $chocoId -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SUCCESS: $chocoId installed via choco." -ForegroundColor Green
            } else {
                Write-Host "ERROR: Failed to install $chocoId via choco." -ForegroundColor Red
            }
        } catch {
            Write-Host "ERROR: Exception while installing $chocoId via choco." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Choco not available! Skipping choco packages." -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "   INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
Write-Host "Script completed. You may now close this window." -ForegroundColor Cyan
