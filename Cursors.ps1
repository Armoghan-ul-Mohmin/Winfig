
# ============================
#   Cursors Symlink Setup
# ============================

param(
    [string]$SourceFolder = (Join-Path -Path $PSScriptRoot -ChildPath 'Assets/Cursors'),
    [string]$TargetFolder = "C:\Windows\Resources\Cursors",
    [switch]$Force = $true
)

# Require admin rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Administrator privileges required!" -ForegroundColor Red
    exit 1
}

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "   CURSOR SYMLINK SETUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
Write-Host "Source folder: $SourceFolder" -ForegroundColor White
Write-Host "Target folder: $TargetFolder" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Gray

function New-CursorSymlink {
    param(
        [string]$Source,
        [string]$Target,
        [switch]$ForceRemove = $true
    )

    # Check source exists
    if (-not (Test-Path $Source)) {
        Write-Host "ERROR: Source 'Cursors' folder not found!" -ForegroundColor Red
        return $false
    }

    # Create target parent if needed
    $parent = Split-Path $Target -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
        Write-Host "Created parent directory: $parent" -ForegroundColor Green
    }

    # Remove existing target if requested
    if ($ForceRemove -and (Test-Path $Target)) {
        Write-Host "Removing existing target..." -ForegroundColor Yellow
        Remove-Item $Target -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Create symlink
    try {
        $symlink = New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force
        if ($symlink) {
            Write-Host "SUCCESS: Symbolic link created!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ERROR: Failed to create symbolic link" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: $_" -ForegroundColor Red
        return $false
    }
}

function Verify-CursorSymlink {
    param([string]$Target)
    $item = Get-Item $Target -ErrorAction SilentlyContinue
    if ($item -and $item.Attributes -match 'ReparsePoint') {
        Write-Host "Symlink verified!" -ForegroundColor Green
        return $true
    } elseif (Test-Path $Target) {
        Write-Host "Directory exists but may not be a symlink." -ForegroundColor Yellow
        return $false
    } else {
        Write-Host "Target does not exist." -ForegroundColor Red
        return $false
    }
}


# Main logic
$success = New-CursorSymlink -Source $SourceFolder -Target $TargetFolder -ForceRemove:$Force
$verified = $false
if ($success) {
    $verified = Verify-CursorSymlink -Target $TargetFolder
}

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "   OPERATION SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray
Write-Host "Source: $SourceFolder" -ForegroundColor White
Write-Host "Target: $TargetFolder" -ForegroundColor White
Write-Host "Symlink created: $success" -ForegroundColor Green
Write-Host "Symlink verified: $verified" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Gray

# Interactive selection for cursor style
$cursorStyles = @("Sunity", "Win 11 Concept")
Write-Host "Available cursor styles:" -ForegroundColor Cyan
for ($i = 0; $i -lt $cursorStyles.Count; $i++) {
    Write-Host "$($i+1). $($cursorStyles[$i])" -ForegroundColor White
}
$styleChoice = Read-Host "Enter the number for your desired cursor style"
if ($styleChoice -notmatch '^[12]$') {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    exit 1
}
$selectedStyle = $cursorStyles[$styleChoice - 1]

# Interactive selection for theme
$themes = @("Dark", "Light")
Write-Host "Available themes:" -ForegroundColor Cyan
for ($i = 0; $i -lt $themes.Count; $i++) {
    Write-Host "$($i+1). $($themes[$i])" -ForegroundColor White
}
$themeChoice = Read-Host "Enter the number for your desired theme"
if ($themeChoice -notmatch '^[12]$') {
    Write-Host "Invalid selection. Exiting." -ForegroundColor Red
    exit 1
}
$selectedTheme = $themes[$themeChoice - 1]

# Build path to selected folder
$finalFolder = Join-Path -Path $SourceFolder -ChildPath "$selectedStyle/$selectedTheme"
if (-not (Test-Path $finalFolder)) {
    Write-Host "Selected folder does not exist: $finalFolder" -ForegroundColor Red
    exit 1
}

# Open the selected folder in Explorer
Start-Process explorer.exe $finalFolder

Start-Sleep -Seconds 4

# Show instructions in a MessageBox
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "Cursor Installation Instructions:`n`n" +
    "1. In the opened folder, right-click the 'install' file and choose 'Install'.`n" +
    "2. Follow the prompts to complete installation.`n`n" +
    "Tip: You may need administrator privileges.",
    "Winfig Cursor Setup",
    [System.Windows.MessageBoxButton]::OK,
    [System.Windows.MessageBoxImage]::Information
)

Write-Host "Script completed. You may now close this window." -ForegroundColor Cyan
