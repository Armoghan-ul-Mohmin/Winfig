#!/usr/bin/env pwsh
<#
===============================================================================
 Script Name  : bootstrap.ps1
 Author       : Armoghan-ul-Mohmin
 Date         : 2025-09-16
 Version      : 2.0.0
-------------------------------------------------------------------------------
 Description:
    Bootstraps the Winfig project environment with a beautiful TUI interface
    Automates essential setup tasks with enhanced visual experience

 Workflow:
    1. Set PowerShell execution policy
    2. Install package managers (Winget, Chocolatey)
    3. Install Git
    4. Clone the Winfig project repository
    5. Install required fonts
    6. Configure dotfiles

-------------------------------------------------------------------------------
 Usage:
    # Run directly from the web:
        1. Run PowerShell as Administrator
        2. Execute the following command:
            iwr -useb https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1 | iex

    # Execute after downloading:
        1. Download bootstrap.ps1 to your local machine
        2. Open PowerShell as Administrator
        3. Navigate to the download directory
        4. Run: ./bootstrap.ps1

-------------------------------------------------------------------------------
 Notes:
    - Run as administrator for installation steps
    - Internet connection required for package downloads
===============================================================================
#>

# ============================================================================ #
#                               Global Variables                               #
# ============================================================================ #

$Global:ScriptMeta = @{
    Author      = "Armoghan-ul-Mohmin"
    Version     = "2.0.0"
    Description = "Beautiful TUI for Winfig project bootstrap"
}

$Global:Colors = @{
    Primary    = "Cyan"
    Success    = "Green"
    Warning    = "Yellow"
    Error      = "Red"
    Accent     = "Magenta"
    Light      = "White"
    Dark       = "Gray"
    Highlight  = "Yellow"
}

$Global:Scopes   = @("MachinePolicy", "UserPolicy", "Process", "CurrentUser", "LocalMachine")
$Global:Policies = @("Restricted", "RemoteSigned", "Unrestricted", "Bypass", "AllSigned")
$Global:RepoUrl  = "https://github.com/Armoghan-ul-Mohmin/winfig.git"

$Global:OneDrivePath   = "$env:USERPROFILE\OneDrive\Documents"
$Global:LocalDocsPath  = "$env:USERPROFILE\Documents"
$Global:RepoPath       = if (Test-Path $Global:OneDrivePath) {
    "$Global:OneDrivePath\winfig"
} else {
    "$Global:LocalDocsPath\winfig"
}
$Global:InstallFontsScript = Join-Path $Global:RepoPath "Install-Fonts.ps1"

# --- Prevent infinite elevation loops when run via iwr|iex ------------------
$global:WinfigElevFlag = Join-Path $env:TEMP "winfig_elev_attempt.flag"
if (Test-Path $global:WinfigElevFlag) {
    if (-not (Test-Administrator)) {
        Show-Error "Previous elevation attempt failed. Run PowerShell as Administrator and re-run this script."
        exit 1
    } else {
        # Elevated child: remove the flag and continue
        Remove-Item $global:WinfigElevFlag -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================================ #
#                               Functions                                      #
# ============================================================================ #

function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color -NoNewline
}

function Show-Header {
    param([string]$Title, [string]$Subtitle = "")

    Write-Color "  =======================================================" $Global:Colors.Primary
    Write-Host ""
    Write-Color "  " $Global:Colors.Primary
    Write-Color $Title $Global:Colors.Highlight
    Write-Host ""
    if ($Subtitle) {
        Write-Color "  " $Global:Colors.Primary
        Write-Color $Subtitle $Global:Colors.Light
        Write-Host ""
    }
    Write-Color "  =======================================================" $Global:Colors.Primary
    Write-Host ""
    Write-Host ""
}

function Show-Step {
    param(
        [int]$StepNo,
        [string]$StepTitle,
        [string]$StepDescription,
        [string]$Status = ""
    )

    Write-Color "  [" $Global:Colors.Primary
    Write-Color "STEP $StepNo" $Global:Colors.Highlight
    Write-Color "] " $Global:Colors.Primary
    Write-Color $StepTitle $Global:Colors.Light

    if ($Status) {
        Write-Color " [" $Global:Colors.Primary
        Write-Color $Status $Global:Colors.Success
        Write-Color "]" $Global:Colors.Primary
    }

    Write-Host ""
    if ($StepDescription) {
        Write-Color "  -> " $Global:Colors.Dark
        Write-Color $StepDescription $Global:Colors.Light
        Write-Host ""
    }
    Write-Host ""
}

function Show-Progress {
    param(
        [string]$Message,
        [bool]$Complete = $false
    )

    if ($Complete) {
        Write-Color "  [OK] " $Global:Colors.Success
        Write-Color $Message $Global:Colors.Light
        Write-Host ""
    } else {
        Write-Color "  [...] " $Global:Colors.Warning
        Write-Color $Message $Global:Colors.Light
        Write-Host ""
    }
}

function Show-Error {
    param([string]$Message)
    Write-Color "  [ERROR] " $Global:Colors.Error
    Write-Color $Message $Global:Colors.Light
    Write-Host ""
}

function Show-Success {
    param([string]$Message)
    Write-Color "  [SUCCESS] " $Global:Colors.Success
    Write-Color $Message $Global:Colors.Light
    Write-Host ""
}

function Show-Warning {
    param([string]$Message)
    Write-Color "  [WARNING] " $Global:Colors.Warning
    Write-Color $Message $Global:Colors.Light
    Write-Host ""
}

function Show-Menu {
    param(
        [string]$Title,
        [array]$Options,
        [string]$Prompt = "Select an option"
    )

    Write-Host ""
    Write-Color "  $Title" $Global:Colors.Primary
    Write-Host ""
    Write-Host ""

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Color "    " $Global:Colors.Primary
        Write-Color "[$($i+1)]" $Global:Colors.Highlight
        Write-Color " " $Global:Colors.Primary
        Write-Color $Options[$i] $Global:Colors.Light
        Write-Host ""
    }

    Write-Host ""
    do {
        Write-Color "  $Prompt (1-$($Options.Count)): " $Global:Colors.Primary
        $choice = Read-Host
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Count) {
            return [int]$choice - 1
        }
        Show-Error "Invalid selection. Please enter a number between 1 and $($Options.Count)"
    } while ($true)
}

function Invoke-WithProgress {
    param(
        [string]$Message,
        [scriptblock]$ScriptBlock,
        [string]$SuccessMessage,
        [string]$ErrorMessage
    )

    Show-Progress -Message $Message
    try {
        $result = & $ScriptBlock
        if ($SuccessMessage) {
            Show-Success $SuccessMessage
        }
        return $result
    } catch {
        Show-Error "$ErrorMessage : $($_.Exception.Message)"
        return $null
    }
}

# ============================================================================ #
#                               Core Functions                                 #
# ============================================================================ #

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-Elevation {
    # create a persistent flag to detect repeated attempts
    try { New-Item -Path $global:WinfigElevFlag -ItemType File -Force | Out-Null } catch {}

    if ($PSCommandPath) {
        # We have a local file path; re-run that file elevated
        $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    }
    else {
        # Running via iwr|iex — re-run the remote raw bootstrap URL elevated
        $rawUrl = "https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1"
        $escaped = "iwr -UseBasicParsing -Uri '$rawUrl' | iex"
        $arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$escaped`""
    }

    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Start-Process pwsh.exe -Verb RunAs -ArgumentList $arguments
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
    }

    # Exit the current (non-elevated) process so elevated instance can continue
    exit
}

# ============================================================================ #
#                               Main Script                                    #
# ============================================================================ #

# Check elevation
if (-not (Test-Administrator)) {
    Show-Header "Winfig Bootstrap" "Administrator privileges required"
    Write-Color "  This script requires administrator privileges to install software." $Global:Colors.Warning
    Write-Host ""
    Write-Color "  Press any key to continue with elevation..." $Global:Colors.Light
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Request-Elevation
}

# Clear screen and set encoding
Clear-Host
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Show welcome screen
Show-Header "Winfig Bootstrap" "Setting up your development environment"

# --- Step 1: Set PowerShell Execution Policy ---
Show-Step -StepNo 1 -StepTitle "Execution Policy Configuration" -StepDescription "Configuring script execution permissions"

$executionPolicies = Get-ExecutionPolicy -List
Write-Host ""
Write-Color "  Current Execution Policies:" $Global:Colors.Primary
Write-Host ""
$executionPolicies | Format-Table -Property Scope, ExecutionPolicy -AutoSize | Out-String | ForEach-Object {
    Write-Color "  $_" $Global:Colors.Light
}

$scopeChoice = Show-Menu -Title "Select scope to modify:" -Options $Global:Scopes -Prompt "Enter scope number"
$selectedScope = $Global:Scopes[$scopeChoice]

$policyChoice = Show-Menu -Title "Select execution policy:" -Options $Global:Policies -Prompt "Enter policy number"
$selectedPolicy = $Global:Policies[$policyChoice]

Invoke-WithProgress -Message "Setting execution policy..." `
    -ScriptBlock { Set-ExecutionPolicy -Scope $selectedScope -ExecutionPolicy $selectedPolicy -Force } `
    -SuccessMessage "Execution policy set to '$selectedPolicy' for scope '$selectedScope'" `
    -ErrorMessage "Failed to set execution policy"

# --- Step 2: Install Package Managers ---
Write-Host ""
Show-Step -StepNo 2 -StepTitle "Package Manager Setup" -StepDescription "Installing Winget and Chocolatey"

# Winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Show-Success "Winget is already installed"
} else {
    $wingetResult = Invoke-WithProgress -Message "Installing Winget..." `
        -ScriptBlock {
            $wingetBundle = "$env:TEMP\winget.msixbundle"
            Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $wingetBundle -UseBasicParsing
            Add-AppxPackage -Path $wingetBundle
            Remove-Item $wingetBundle -Force -ErrorAction SilentlyContinue
            return Get-Command winget -ErrorAction SilentlyContinue
        } `
        -SuccessMessage "Winget installed successfully" `
        -ErrorMessage "Failed to install Winget"

    if (-not $wingetResult) {
        Show-Warning "Please install Winget manually from: https://aka.ms/getwinget"
    }
}

# Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Show-Success "Chocolatey is already installed"
} else {
    $chocoResult = Invoke-WithProgress -Message "Installing Chocolatey..." `
        -ScriptBlock {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            return Get-Command choco -ErrorAction SilentlyContinue
        } `
        -SuccessMessage "Chocolatey installed successfully" `
        -ErrorMessage "Failed to install Chocolatey"

    if (-not $chocoResult) {
        Show-Warning "Please install Chocolatey manually from: https://chocolatey.org/install"
    }
}

# --- Step 3: Install Git ---
Write-Host ""
Show-Step -StepNo 3 -StepTitle "Git Installation" -StepDescription "Installing version control system"

if (Get-Command git -ErrorAction SilentlyContinue) {
    Show-Success "Git is already installed"
} else {
    $gitResult = Invoke-WithProgress -Message "Installing Git via Winget..." `
        -ScriptBlock {
            winget install -e --id Git.Git -h --accept-source-agreements --accept-package-agreements --silent
            return Get-Command git -ErrorAction SilentlyContinue
        } `
        -SuccessMessage "Git installed successfully" `
        -ErrorMessage "Failed to install Git"

    if (-not $gitResult) {
        Show-Warning "Please install Git manually from: https://git-scm.com/downloads"
    }
}

# --- Step 4: Clone Repository ---
Write-Host ""
Show-Step -StepNo 4 -StepTitle "Repository Setup" -StepDescription "Cloning Winfig project repository"

if (Test-Path $Global:RepoPath) {
    Show-Success "Repository already exists at: $Global:RepoPath"
} else {
    $cloneResult = Invoke-WithProgress -Message "Cloning repository..." `
        -ScriptBlock { git clone $Global:RepoUrl $Global:RepoPath } `
        -SuccessMessage "Repository cloned successfully" `
        -ErrorMessage "Failed to clone repository"
}

# --- Step 5: Install Fonts ---
Write-Host ""
Show-Step -StepNo 5 -StepTitle "Font Installation" -StepDescription "Installing required fonts"

if (Test-Path $Global:InstallFontsScript) {
    $fontResult = Invoke-WithProgress -Message "Running font installation script..." `
        -ScriptBlock { & $Global:InstallFontsScript } `
        -SuccessMessage "Fonts installed successfully" `
        -ErrorMessage "Failed to install fonts"
} else {
    Show-Warning "Font installation script not found at: $Global:InstallFontsScript"
}

# --- Step 6: Dotfiles Configuration ---
Write-Host ""
Show-Step -StepNo 6 -StepTitle "Dotfiles Setup" -StepDescription "Configuring user settings (Coming Soon)"
Show-Progress -Message "Dotfiles configuration is under development" -Complete $true

# --- Completion ---
Write-Host ""
Show-Header "Setup Complete" "Your Winfig environment is ready!"
Write-Host ""
Write-Color "  Congratulations! Your development environment has been set up." $Global:Colors.Success
Write-Host ""
Write-Color "  Repository location: " $Global:Colors.Primary
Write-Color $Global:RepoPath $Global:Colors.Light
Write-Host ""
Write-Color "  Next steps:" $Global:Colors.Primary
Write-Host ""
Write-Color "    1. Explore the cloned repository" $Global:Colors.Light
Write-Host ""
Write-Color "    2. Review the documentation" $Global:Colors.Light
Write-Host ""
Write-Color "    3. Start customizing your environment" $Global:Colors.Light
Write-Host ""
Write-Host ""
Write-Color "  Press any key to exit..." $Global:Colors.Dark
$opts = [System.Management.Automation.Host.ReadKeyOptions]::NoEcho -bor `
        [System.Management.Automation.Host.ReadKeyOptions]::IncludeKeyDown
$null = $Host.UI.RawUI.ReadKey($opts)
