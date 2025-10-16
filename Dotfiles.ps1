[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipBackup,
    [string]$LogPath = ""
)

# Set console encoding
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSDefaultParameterValues['*:Encoding'] = 'utf8'
} else {
    $OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

# ============================================================================ #
#                               GLOBAL VARIABLES                               #
# ============================================================================ #

# Script metadata
$Script:ScriptMeta = @{
    Name         = "Winfig Dotfiles Installer"
    Version      = "1.0.0"
    Author       = "Armoghan-ul-Mohmin"
    Description  = "Installs and manages dotfiles using symbolic links."
    PowerShell   = $PSVersionTable.PSVersion.ToString()
    StartTime    = Get-Date
}

# Color scheme for output
$Script:Colors = @{
    Primary     = "Cyan"
    Secondary   = "Magenta"
    Success     = "Green"
    Warning     = "Yellow"
    Error       = "Red"
    Info        = "White"
    Debug       = "Gray"
    Accent      = "Blue"
    Highlight   = "DarkYellow"
}

$Global:TempDir = [Environment]::GetEnvironmentVariable("TEMP")

# Configuration settings
$Script:Config = @{
    ConfigDirectory   = Join-Path $PSScriptRoot "config"
    DotfilesDirectory = Join-Path $PSScriptRoot "Dotfiles"
    DotfilesJsonFile  = "Dotfiles.json"
    LogDirectory      = [System.IO.Path]::Combine($Global:TempDir, "Winfig-Logs")
}

# Global variables
$Global:LogFile = $null
$Global:DotfileStats = @{
    Total = 0
    Installed = 0
    Skipped = 0
    Failed = 0
    BackedUp = 0
}

# ============================================================================ #
#                              UTILITY FUNCTIONS                               #
# ============================================================================ #

function Initialize-Logging {
    try {
        # Create logs directory if it doesn't exist
        if (-not (Test-Path $Script:Config.LogDirectory)) {
            New-Item -ItemType Directory -Path $Script:Config.LogDirectory -Force | Out-Null
        }

        # Generate timestamped log filename
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $Global:LogFile = [System.IO.Path]::Combine($Script:Config.LogDirectory, "Dotfiles-$timestamp.log")

        # Initialize log file
        Write-LogEntry -Message "=== Winfig Dotfiles Installer Started ===" -Level "INFO"
        Write-LogEntry -Message "Version: $($Script:ScriptMeta.Version)" -Level "INFO"
        Write-LogEntry -Message "PowerShell Version: $($Script:ScriptMeta.PowerShell)" -Level "INFO"
        Write-LogEntry -Message "Log File: $Global:LogFile" -Level "INFO"

        return $true
    }
    catch {
        Write-Host "Failed to initialize logging: $($_.Exception.Message)" -ForegroundColor $Script:Colors.Error
        return $false
    }
}

function Write-LogEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG", "SUCCESS")]
        [string]$Level = "INFO"
    )

    try {
        if ($Global:LogFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] [$Level] $Message"
            Add-Content -Path $Global:LogFile -Value $logEntry -Encoding UTF8
        }
    }
    catch {
        # Silent fail for logging to prevent infinite loops
    }
}

function Write-ColorOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Color = "White",

        [Parameter(Mandatory = $false)]
        [string]$Level = "INFO",

        [switch]$NoNewline
    )

    # Simple output without complex formatting
    Write-Host $Message -ForegroundColor $Color
    Write-LogEntry -Message $Message -Level $Level
}

function Write-StatusMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("SUCCESS", "ERROR", "WARNING", "INFO")]
        [string]$Type = "INFO"
    )

    $symbol = switch ($Type) {
        "SUCCESS" { "[+]" }
        "ERROR"   { "[X]" }
        "WARNING" { "[!]" }
        "INFO"    { "[i]" }
    }

    $color = switch ($Type) {
        "SUCCESS" { $Script:Colors.Success }
        "ERROR"   { $Script:Colors.Error }
        "WARNING" { $Script:Colors.Warning }
        "INFO"    { $Script:Colors.Info }
    }

    $statusMessage = "$symbol $Message"
    Write-Host $statusMessage -ForegroundColor $color
    Write-LogEntry -Message $statusMessage -Level $Type
}

function Show-Banner {
    Clear-Host
    Start-Sleep -Milliseconds 100

    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                 WINFIG DOTFILES INSTALLER                     " -ForegroundColor Magenta
    Write-Host "                     Version $($Script:ScriptMeta.Version)                         " -ForegroundColor White
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Advanced Dotfiles Management System" -ForegroundColor Blue
    Write-Host ""
}

function Test-Prerequisites {
    Write-StatusMessage "Checking system prerequisites..." -Type "INFO"

    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
    if (-not $isAdmin) {
        Write-StatusMessage "Administrator privileges required. Please run as Administrator." -Type "ERROR"
        return $false
    }
    Write-StatusMessage "Administrator privileges confirmed" -Type "SUCCESS"

    # Check Dotfiles directory
    if (-not (Test-Path $Script:Config.DotfilesDirectory)) {
        Write-StatusMessage "Dotfiles directory not found: $($Script:Config.DotfilesDirectory)" -Type "ERROR"
        return $false
    }
    Write-StatusMessage "Dotfiles directory found" -Type "SUCCESS"

    # Check config directory
    if (-not (Test-Path $Script:Config.ConfigDirectory)) {
        Write-StatusMessage "Config directory not found: $($Script:Config.ConfigDirectory)" -Type "ERROR"
        return $false
    }
    Write-StatusMessage "Config directory found" -Type "SUCCESS"

    return $true
}

function Expand-EnvironmentVariables {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Replace PowerShell environment variables
    $expandedPath = $Path

    # Common environment variables used in JSON
    $envVars = @{
        '$env:USERPROFILE' = $env:USERPROFILE
        '$env:APPDATA' = $env:APPDATA
        '$env:LOCALAPPDATA' = $env:LOCALAPPDATA
        '$env:PROGRAMFILES' = $env:PROGRAMFILES
        '$env:PROGRAMDATA' = $env:PROGRAMDATA
        '$env:HOMEDRIVE' = $env:HOMEDRIVE
        '$env:HOMEPATH' = $env:HOMEPATH
    }

    foreach ($var in $envVars.Keys) {
        $expandedPath = $expandedPath -replace [regex]::Escape($var), $envVars[$var]
    }

    return $expandedPath
}


# ============================================================================ #
#                           JSON PROCESSING FUNCTIONS                          #
# ============================================================================ #

function Read-DotfilesJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        if (-not (Test-Path $FilePath)) {
            Write-StatusMessage -Message "JSON file not found: $FilePath" -Type "ERROR"
            return $null
        }

        Write-LogEntry "Reading dotfiles configuration: $FilePath" "INFO"

        # Read and parse JSON (PowerShell 5.x and 7.x compatible)
        $jsonContent = Get-Content -Path $FilePath -Raw -Encoding UTF8
        $dotfiles = $jsonContent | ConvertFrom-Json

        # Ensure it's an array
        if ($dotfiles -isnot [Array]) {
            $dotfiles = @($dotfiles)
        }

        Write-StatusMessage "Loaded $($dotfiles.Count) dotfile configurations" -Type "SUCCESS"
        $Global:DotfileStats.Total = $dotfiles.Count

        return $dotfiles
    }
    catch {
        Write-StatusMessage -Message "Failed to read or parse JSON file: $($_.Exception.Message)" -Type "ERROR"
        return $null
    }
}

function Get-AllDotfiles {
    # Read dotfiles configuration
    $dotfilesPath = Join-Path $Script:Config.ConfigDirectory $Script:Config.DotfilesJsonFile
    $dotfiles = Read-DotfilesJsonFile -FilePath $dotfilesPath

    if (-not $dotfiles) {
        Write-StatusMessage "No dotfiles configuration found" -Type "ERROR"
        return @()
    }

    Write-StatusMessage "Total dotfiles to process: $($dotfiles.Count)" -Type "INFO"
    Write-LogEntry "Dotfiles summary - Total: $($dotfiles.Count)" "INFO"

    return $dotfiles
}

# ============================================================================ #
#                          BACKUP AND SYMLINK FUNCTIONS                       #
# ============================================================================ #

function Request-BackupPermission {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetPath,
        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if ($SkipBackup) {
        Write-StatusMessage "Skipping backup (SkipBackup parameter specified)" -Type "WARNING"
        return $false
    }

    if ($Force) {
        Write-StatusMessage "Force backup enabled" -Type "INFO"
        return $true
    }

    Write-Host ""
    Write-Host "Target already exists: $TargetPath" -ForegroundColor $Script:Colors.Warning
    Write-Host "Description: $Description" -ForegroundColor $Script:Colors.Info
    Write-Host ""

    do {
        Write-Host "Do you want to backup the existing file/folder? (y/n): " -ForegroundColor $Script:Colors.Highlight -NoNewline
        $choice = Read-Host
        $choice = $choice.ToLower().Trim()
    } while ($choice -ne 'y' -and $choice -ne 'n' -and $choice -ne 'yes' -and $choice -ne 'no')

    return ($choice -eq 'y' -or $choice -eq 'yes')
}

function Backup-ExistingTarget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    try {
        $backupPath = "$TargetPath.bak"

        # If backup already exists, add timestamp
        if (Test-Path $backupPath) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$TargetPath.bak.$timestamp"
        }

        # Perform backup
        if (Test-Path $TargetPath -PathType Container) {
            # It's a directory
            Move-Item -Path $TargetPath -Destination $backupPath -Force
        } else {
            # It's a file
            Move-Item -Path $TargetPath -Destination $backupPath -Force
        }

        Write-StatusMessage "Backed up to: $backupPath" -Type "SUCCESS"
        Write-LogEntry "Backed up $TargetPath to $backupPath" "SUCCESS"
        $Global:DotfileStats.BackedUp++

        return $true
    }
    catch {
        Write-StatusMessage "Failed to backup $TargetPath : $($_.Exception.Message)" -Type "ERROR"
        Write-LogEntry "Backup failed for $TargetPath : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function New-SymbolicLinkDotfile {
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$Dotfile
    )

    # Validate required properties
    if (-not $Dotfile.source -or -not $Dotfile.target -or -not $Dotfile.description) {
        Write-StatusMessage "Invalid dotfile configuration - missing required properties" -Type "ERROR"
        return $false
    }

    # Construct full source path
    $sourcePath = Join-Path $Script:Config.DotfilesDirectory $Dotfile.source

    # Expand environment variables in target path
    $targetPath = Expand-EnvironmentVariables -Path $Dotfile.target

    Write-Host ""
    Write-Host "Processing: $($Dotfile.description)" -ForegroundColor White
    Write-LogEntry -Message "Processing: $($Dotfile.description)" -Level "INFO"
    Write-Host "Source: $sourcePath" -ForegroundColor $Script:Colors.Debug
    Write-Host "Target: $targetPath" -ForegroundColor $Script:Colors.Debug

    # Check if source exists
    if (-not (Test-Path $sourcePath)) {
        Write-StatusMessage "Source not found: $sourcePath" -Type "ERROR"
        Write-LogEntry "Source not found: $sourcePath" "ERROR"
        $Global:DotfileStats.Failed++
        return $false
    }

    # Check if target already exists
    if (Test-Path $targetPath) {
        # Check if it's already a symbolic link pointing to the correct source
        $item = Get-Item $targetPath -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            try {
                $linkTarget = $item.Target
                if ($linkTarget -eq $sourcePath) {
                    Write-StatusMessage "Already linked correctly" -Type "SUCCESS"
                    $Global:DotfileStats.Skipped++
                    return $true
                }
            }
            catch {
                # Continue with backup/replace logic
            }
        }

        # Ask for backup permission
        if (Request-BackupPermission -TargetPath $targetPath -Description $Dotfile.description) {
            if (-not (Backup-ExistingTarget -TargetPath $targetPath)) {
                $Global:DotfileStats.Failed++
                return $false
            }
        } else {
            Write-StatusMessage "Skipped due to user choice" -Type "WARNING"
            $Global:DotfileStats.Skipped++
            return $true
        }
    }

    # Create target directory if needed
    $targetDir = Split-Path $targetPath -Parent
    if (-not (Test-Path $targetDir)) {
        try {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            Write-StatusMessage "Created target directory: $targetDir" -Type "INFO"
        }
        catch {
            Write-StatusMessage "Failed to create target directory: $($_.Exception.Message)" -Type "ERROR"
            $Global:DotfileStats.Failed++
            return $false
        }
    }

    # Create symbolic link
    try {
        if ($Dotfile.type -eq "folder" -or (Test-Path $sourcePath -PathType Container)) {
            # Create directory junction/symlink
            New-Item -ItemType Junction -Path $targetPath -Target $sourcePath -Force | Out-Null
            Write-StatusMessage "Directory symlink created successfully" -Type "SUCCESS"
        } else {
            # Create file symlink
            New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
            Write-StatusMessage "File symlink created successfully" -Type "SUCCESS"
        }

        Write-LogEntry "Symlink created: $targetPath -> $sourcePath" "SUCCESS"
        $Global:DotfileStats.Installed++
        return $true
    }
    catch {
        Write-StatusMessage "Failed to create symlink: $($_.Exception.Message)" -Type "ERROR"
        Write-LogEntry "Symlink creation failed: $targetPath -> $sourcePath. Error: $($_.Exception.Message)" "ERROR"
        $Global:DotfileStats.Failed++
        return $false
    }
}

# ============================================================================ #
#                              MAIN EXECUTION                                  #
# ============================================================================ #

function Show-Summary {
    $duration = (Get-Date) - $Script:ScriptMeta.StartTime
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                     DOTFILES SUMMARY                          " -ForegroundColor Magenta
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host " Total Dotfiles:        $($Global:DotfileStats.Total) configurations processed" -ForegroundColor White
    Write-Host " Successfully Installed: $($Global:DotfileStats.Installed) symlinks created" -ForegroundColor Green
    Write-Host " Already Linked:         $($Global:DotfileStats.Skipped) symlinks skipped" -ForegroundColor Yellow
    Write-Host " Backed Up:              $($Global:DotfileStats.BackedUp) files/folders backed up" -ForegroundColor Yellow
    Write-Host " Failed Installations:   $($Global:DotfileStats.Failed) symlinks failed" -ForegroundColor Red
    Write-Host " Execution Time:         $($duration.ToString('mm\:ss')) minutes" -ForegroundColor White
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-LogEntry "=== Dotfiles Installation Summary ===" "INFO"
    Write-LogEntry "Total: $($Global:DotfileStats.Total), Installed: $($Global:DotfileStats.Installed), Skipped: $($Global:DotfileStats.Skipped), Failed: $($Global:DotfileStats.Failed), Backed Up: $($Global:DotfileStats.BackedUp)" "INFO"
    Write-LogEntry "Execution time: $($duration.ToString())" "INFO"
    Write-LogEntry "=== Winfig Dotfiles Installer Completed ===" "INFO"

    if ($Global:DotfileStats.Failed -gt 0) {
        Write-StatusMessage "Some dotfiles failed to install. Check the log file for details: $Global:LogFile" -Type "WARNING"
    }
    elseif ($Global:DotfileStats.Installed -gt 0) {
        Write-StatusMessage "Dotfiles installation completed successfully!" -Type "SUCCESS"
    }
    else {
        Write-StatusMessage "No new dotfiles were installed." -Type "INFO"
    }
}

function Main {
    try {
        # Show banner
        Show-Banner

        # Initialize logging
        if (-not (Initialize-Logging)) {
            Write-Host "Failed to initialize logging. Continuing without logging..." -ForegroundColor Yellow
        }

        # Check prerequisites
        if (-not (Test-Prerequisites)) {
            Write-StatusMessage "Prerequisites check failed. Exiting..." -Type "ERROR"
            return
        }

        # Get all dotfiles
        $dotfiles = Get-AllDotfiles
        if (-not $dotfiles -or $dotfiles.Count -eq 0) {
            Write-StatusMessage "No dotfiles found to process. Exiting..." -Type "ERROR"
            return
        }

        Write-Host ""
        Write-StatusMessage "Starting dotfiles installation..." -Type "INFO"

        # Process each dotfile
        foreach ($dotfile in $dotfiles) {
            New-SymbolicLinkDotfile -Dotfile $dotfile
        }

        # Show summary
        Show-Summary

        # Final message
        Write-Host ""
        if ($Global:LogFile) {
            Write-Host "Detailed log available at: $Global:LogFile" -ForegroundColor $Script:Colors.Info
        }
        Write-Host ""
    }
    catch {
        Write-StatusMessage "Fatal error occurred: $($_.Exception.Message)" -Type "ERROR"
        Write-LogEntry "Fatal error: $($_.Exception.Message)" "ERROR"
        Write-LogEntry "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    }
}

# ============================================================================ #
#                                 EXECUTION                                    #
# ============================================================================ #

# Run main function
Main
