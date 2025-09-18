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

function Test-Prerequisites {
    Show-Progress "Checking system prerequisites..."

    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Show-Error "Windows 10 or later is required. Current version: $($osVersion)"
        return $false
    }

    # Check internet connection
    try {
        $null = Invoke-WebRequest -Uri "https://github.com" -UseBasicParsing -TimeoutSec 2
    } catch {
        Show-Error "Internet connection is required but not available"
        return $false
    }

    # Check available disk space
    $drive = Get-PSDrive -Name (Get-Location).Drive.Name
    if ($drive.Free / 1GB -lt 2) {
        Show-Warning "Low disk space (less than 2GB free). Installation may fail."
    }

    return $true
}

function Test-RestorePointCapability {
    # Check if we can create restore points
    try {
        # Check if we're on Windows
        if ((-not $IsWindows) -and ($env:OS -ne "Windows_NT")) {
            return $false
        }

        # Check Windows edition (only available on Workstation versions)
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        if ($os.ProductType -ne 1) { # Not Workstation version
            return $false
        }

        # Check if System Restore is enabled
        try {
            $restoreSettings = Get-ComputerRestorePoint -ErrorAction Stop
            if (-not $restoreSettings) {
                return $false
            }
        } catch {
            # If we can't check restore settings, assume it might be available
        }

        return $true
    } catch {
        return $false
    }
}

function New-RestorePoint {
    param(
        [string]$Description = "Winfig Bootstrap Installation",
        [ValidateSet("APPLICATION_INSTALL", "APPLICATION_UNINSTALL", "DEVICE_DRIVER_INSTALL", "MODIFY_SETTINGS")]
        [string]$EventType = "APPLICATION_INSTALL"
    )

    try {
        # First try using Checkpoint-Computer (Windows 8.1/Server 2012 R2 and later)
        if (Get-Command Checkpoint-Computer -ErrorAction SilentlyContinue) {
            $restorePointName = "Winfig_Bootstrap_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Checkpoint-Computer -Description $restorePointName -RestorePointType $EventType
            return @{ Success = $true; SequenceNumber = 0; Method = "Checkpoint-Computer" }
        }

        # Fallback to P/Invoke method for older systems
        Show-Warning "Checkpoint-Computer not available, trying P/Invoke method"

        # Load the required assembly
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class SystemRestore {
                [DllImport("srclient.dll")]
                public static extern int SRSetRestorePointW(ref RESTOREPOINTINFO pRestorePtSpec, out STATEMGRSTATUS pSMgrStatus);

                [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
                public struct RESTOREPOINTINFO {
                    public int dwEventType;
                    public int dwRestorePtType;
                    public long llSequenceNumber;
                    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)]
                    public string szDescription;
                }

                [StructLayout(LayoutKind.Sequential)]
                public struct STATEMGRSTATUS {
                    public uint nStatus;
                    public long llSequenceNumber;
                }
            }
"@ -ErrorAction Stop

        # Create restore point information
        $restoreInfo = New-Object -TypeName "SystemRestore+RESTOREPOINTINFO"
        $restoreInfo.dwEventType = 100  # BEGIN_SYSTEM_CHANGE
        $restoreInfo.dwRestorePtType = 0  # APPLICATION_INSTALL
        $restoreInfo.llSequenceNumber = 0
        $restoreInfo.szDescription = $Description

        $status = New-Object -TypeName "SystemRestore+STATEMGRSTATUS"

        # Create the restore point
        $result = [SystemRestore]::SRSetRestorePointW([ref]$restoreInfo, [ref]$status)

        if ($result -eq 0) {
            return @{ Success = $true; SequenceNumber = $status.llSequenceNumber; Method = "P/Invoke" }
        } else {
            return @{ Success = $false; Error = "Failed to create restore point. Error code: $result" }
        }
    } catch {
        # If both methods fail, check if system restore is enabled
        try {
            $systemRestore = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
            if (-not $systemRestore) {
                return @{ Success = $false; Error = "System Restore is not enabled on this system" }
            }
        } catch {}

        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Request-RestorePoint {
    $choice = Show-Menu -Title "System Restore Point" `
        -Options @("Yes, create a system restore point (recommended)", "No, continue without restore point") `
        -Prompt "Would you like to create a system restore point before proceeding?"

    if ($choice -eq 0) {
        Show-Progress "Creating system restore point..."

        if (-not (Test-RestorePointCapability)) {
            Show-Warning "System restore points are not available on this Windows edition"

            $continueChoice = Show-Menu -Title "Continue Installation?" `
                -Options @("Yes, continue without restore point", "No, exit the installation") `
                -Prompt "Would you like to continue without a restore point?"

            return ($continueChoice -eq 0)
        }

        $result = New-RestorePoint -Description "Winfig Bootstrap - Pre-installation state"

        if ($result.Success) {
            $message = "System restore point created successfully"
            if ($result.SequenceNumber -ne 0) {
                $message += " (Sequence: $($result.SequenceNumber))"
            }
            Show-Success $message
            return $true
        } else {
            Show-Warning "Failed to create system restore point: $($result.Error)"

            $continueChoice = Show-Menu -Title "Continue Installation?" `
                -Options @("Yes, continue without restore point", "No, exit the installation") `
                -Prompt "Would you like to continue without a restore point?"

            return ($continueChoice -eq 0)
        }
    }

    return $true
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

# Check prerequisites
if (-not (Test-Prerequisites)) {
    exit 1
}

# --- Step 1: Restore Point Creation ---
Write-Host ""
Show-Step -StepNo 1 -StepTitle "System Protection" -StepDescription "Creating restore point before making changes"

if (-not (Request-RestorePoint)) {
    Show-Error "Installation cancelled by user"
    exit 1
}

# --- Step 2: Set PowerShell Execution Policy ---
Write-Host ""
Show-Step -StepNo 2 -StepTitle "Execution Policy Configuration" -StepDescription "Configuring script execution permissions"

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

# --- Step 3: Install Package Managers ---
Write-Host ""
Show-Step -StepNo 3 -StepTitle "Package Manager Setup" -StepDescription "Installing Winget and Chocolatey"

# Winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Show-Success "Winget is already installed"
} else {
    $wingetResult = Invoke-WithProgress -Message "Installing Winget..." `
        -ScriptBlock {
            # First install the required Microsoft UI XAML framework
            $xamlFrameworkUrl = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6"
            $xamlFrameworkTemp = "$env:TEMP\Microsoft.UI.Xaml.2.8.6.nupkg"
            $xamlFrameworkDir = "$env:TEMP\Microsoft.UI.Xaml.2.8.6"

            # Download and extract the XAML framework
            Invoke-WebRequest -Uri $xamlFrameworkUrl -OutFile $xamlFrameworkTemp -UseBasicParsing
            Expand-Archive -Path $xamlFrameworkTemp -DestinationPath $xamlFrameworkDir -Force

            # Find and install the MSIX framework package
            $xamlMsix = Get-ChildItem -Path $xamlFrameworkDir -Recurse -Filter "*.msix" | Where-Object { $_.Name -like "*x64*" -or $_.Name -like "*neutral*" }
            if ($xamlMsix) {
                Add-AppxPackage -Path $xamlMsix.FullName -ErrorAction Stop
            }

            # Clean up temporary files
            Remove-Item $xamlFrameworkTemp -Force -ErrorAction SilentlyContinue
            Remove-Item $xamlFrameworkDir -Recurse -Force -ErrorAction SilentlyContinue

            # Now install Winget
            $wingetBundle = "$env:TEMP\winget.msixbundle"
            $downloadUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

            Invoke-WebRequest -Uri $downloadUrl -OutFile $wingetBundle -UseBasicParsing

            # Verify the file was downloaded correctly
            if (-not (Test-Path $wingetBundle)) {
                throw "Failed to download winget package"
            }

            # Install the package
            Add-AppxPackage -Path $wingetBundle -ErrorAction Stop

            # Clean up
            Remove-Item $wingetBundle -Force -ErrorAction SilentlyContinue

            # Verify installation
            $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
            if (-not $wingetCmd) {
                # Sometimes it needs a moment to register
                Start-Sleep -Seconds 3
                $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
            }

            return $wingetCmd
        } `
        -SuccessMessage "Winget installed successfully" `
        -ErrorMessage "Failed to install Winget"

    if (-not $wingetResult) {
        Show-Warning "Winget installation failed. Trying Store method..."

        # Alternative method using Microsoft Store
        $alternativeResult = Invoke-WithProgress -Message "Opening Microsoft Store for Winget..." `
            -ScriptBlock {
                # Try to open Microsoft Store to App Installer page
                try {
                    Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
                    Write-Host "Please complete the installation in Microsoft Store and press any key to continue..." -ForegroundColor Yellow
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                } catch {
                    # Fallback to URL
                    Start-Process "https://www.microsoft.com/store/productId/9NBLGGH4NNS1"
                    Write-Host "Microsoft Store opened in browser. Please install App Installer and press any key to continue..." -ForegroundColor Yellow
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }

                # Check if installation worked
                Start-Sleep -Seconds 5
                $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
                if (-not $wingetCmd) {
                    Start-Sleep -Seconds 10
                    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
                }

                return $wingetCmd
            } `
            -SuccessMessage "Winget installed via Microsoft Store" `
            -ErrorMessage "Store installation failed"

        if (-not $alternativeResult) {
            Show-Warning "All Winget installation methods failed."
            Show-Warning "Please install Winget manually using one of these methods:"
            Write-Host ""
            Write-Color "  1. Microsoft Store: " -ForegroundColor Yellow -NoNewline
            Write-Host "https://www.microsoft.com/store/productId/9NBLGGH4NNS1" -ForegroundColor Cyan
            Write-Color "  2. Direct download: " -ForegroundColor Yellow -NoNewline
            Write-Host "https://aka.ms/getwinget" -ForegroundColor Cyan
            Write-Host ""
            Write-Color "  After installation, please restart PowerShell and run this script again." -ForegroundColor Yellow
            Write-Host ""

            $continueChoice = Show-Menu -Title "Continue without Winget?" `
                -Options @("Yes, continue without Winget", "No, exit and install manually") `
                -Prompt "Some features may not work without Winget"

            if ($continueChoice -ne 0) {
                exit 1
            }
        }
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

# --- Step 4: Install Git ---
Write-Host ""
Show-Step -StepNo 4 -StepTitle "Git Installation" -StepDescription "Installing version control system"

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

# --- Step 5: Clone Repository ---
Write-Host ""
Show-Step -StepNo 5 -StepTitle "Repository Setup" -StepDescription "Cloning Winfig project repository"

if (Test-Path $Global:RepoPath) {
    Show-Success "Repository already exists at: $Global:RepoPath"
} else {
    $cloneResult = Invoke-WithProgress -Message "Cloning repository..." `
        -ScriptBlock { git clone $Global:RepoUrl $Global:RepoPath } `
        -SuccessMessage "Repository cloned successfully" `
        -ErrorMessage "Failed to clone repository"
}

# --- Step 6: Install Fonts ---
Write-Host ""
Show-Step -StepNo 6 -StepTitle "Font Installation" -StepDescription "Installing required fonts"

if (Test-Path $Global:InstallFontsScript) {
    $fontResult = Invoke-WithProgress -Message "Running font installation script..." `
        -ScriptBlock { & $Global:InstallFontsScript } `
        -SuccessMessage "Fonts installed successfully" `
        -ErrorMessage "Failed to install fonts"
} else {
    Show-Warning "Font installation script not found at: $Global:InstallFontsScript"
}

# --- Step 7: Dotfiles Configuration ---
Write-Host ""
Show-Step -StepNo 7 -StepTitle "Dotfiles Setup" -StepDescription "Configuring user settings (Coming Soon)"
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
