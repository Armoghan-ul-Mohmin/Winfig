# ============================
#   Install Fonts Properly
# ============================

param(
    [string[]]$FontZips = @("Hack.zip", "JetBrainsMono.zip"),
    [string]$SourceFolder = (Join-Path -Path $PSScriptRoot -ChildPath 'Assets'),
    [switch]$SystemWide = $true,
    [switch]$ForceReinstall = $true
)

# Require admin rights for system-wide installation
if ($SystemWide -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "System-wide installation requires Administrator privileges!" -ForegroundColor Red
    exit 1
}

# Set paths based on installation type
if ($SystemWide) {
    $FontFolder = "C:\Windows\Fonts"
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
} else {
    $FontFolder = Join-Path $env:USERPROFILE "AppData\Local\Microsoft\Windows\Fonts"
    $RegPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
}

# Ensure fonts folder exists
New-Item -ItemType Directory -Force -Path $FontFolder | Out-Null

function Install-Font {
    param([string]$FontFile)

    $FontFileName = [System.IO.Path]::GetFileName($FontFile)
    $DestFontFile = Join-Path $FontFolder $FontFileName
    $FontName = [System.IO.Path]::GetFileNameWithoutExtension($FontFile)
    $RegName = "$FontName (TrueType)"

    # Check if font is already registered
    $isRegistered = $false
    try {
        $existingReg = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
        if ($existingReg -and $existingReg.$RegName -eq $FontFileName) {
            $isRegistered = $true
        }
    } catch { }

    # Copy font file if it doesn't exist or force reinstall
    if ($ForceReinstall -or -not (Test-Path $DestFontFile)) {
        Copy-Item $FontFile -Destination $DestFontFile -Force
        Write-Host "Copied font: $FontFileName" -ForegroundColor Green
    } else {
        Write-Host "Font file exists: $FontFileName" -ForegroundColor Yellow
    }

    # Register font in registry (always register, even if file exists)
    try {
        # Remove existing registry entry if it exists
        Remove-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue

        # Add new registry entry
        New-ItemProperty -Path $RegPath -Name $RegName -Value $FontFileName -PropertyType String -Force | Out-Null

        if ($isRegistered) {
            Write-Host "Re-registered font: $FontName" -ForegroundColor Green
        } else {
            Write-Host "Registered font: $FontName" -ForegroundColor Green
        }

    } catch {
        Write-Host "Failed to register font: $FontFileName" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

# Create temp directory for extraction
$TempDir = Join-Path $env:TEMP "FontInstall"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

$totalFonts = 0
$registeredFonts = 0

foreach ($ZipName in $FontZips) {
    $ZipPath = Join-Path $SourceFolder $ZipName

    if (-not (Test-Path $ZipPath)) {
        Write-Host "Missing ZIP file: $ZipName" -ForegroundColor Red
        continue
    }

    try {
        Write-Host "Processing: $ZipName" -ForegroundColor Cyan

        # Clean temp directory
        Remove-Item "$TempDir\*" -Recurse -Force -ErrorAction SilentlyContinue

        # Extract zip to temp directory
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force

        # Find all font files in the extracted contents
        $FontFiles = Get-ChildItem -Path $TempDir -Include "*.ttf", "*.otf", "*.ttc" -Recurse

        if ($FontFiles.Count -eq 0) {
            Write-Host "No font files found in: $ZipName" -ForegroundColor Yellow
            continue
        }

        Write-Host "Found $($FontFiles.Count) font file(s)" -ForegroundColor Green
        $totalFonts += $FontFiles.Count

        foreach ($FontFile in $FontFiles) {
            Install-Font -FontFile $FontFile.FullName
            $registeredFonts++
        }

    } catch {
        Write-Host "Failed to process: $ZipName" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

# Clean up temp directory
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# Refresh font cache more aggressively
Write-Host "Refreshing font cache..." -ForegroundColor Cyan
try {
    # Method 1: Restart font cache service (requires admin)
    if ($SystemWide) {
        Stop-Service -Name FontCache -Force -ErrorAction SilentlyContinue
        Start-Service -Name FontCache -ErrorAction SilentlyContinue
    }

    # Method 2: Use .NET to trigger font cache update
    Add-Type -AssemblyName System.Windows.Forms
    $null = [System.Windows.Forms.TextRenderer]::MeasureText("test", (New-Object System.Drawing.Font "Hack Nerd Font", 12))

    # Method 3: Update registry to force font cache refresh
    $null = [Microsoft.Win32.Registry]::SetValue("HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\FontCache", "FontCacheVer", [Guid]::NewGuid().ToString())

    # Method 4: Restart explorer to refresh font cache
    if ($SystemWide) {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer -ErrorAction SilentlyContinue
    }

    Write-Host "Font cache refreshed successfully" -ForegroundColor Green
} catch {
    Write-Host "Font cache may need manual refresh" -ForegroundColor Yellow
}

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "  FONT INSTALLATION SUMMARY" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Gray
Write-Host "Total fonts processed: $totalFonts" -ForegroundColor White
Write-Host "Fonts registered: $registeredFonts" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Gray

if ($SystemWide) {
    Write-Host "System-wide installation completed." -ForegroundColor Cyan
} else {
    Write-Host "Per-user installation completed." -ForegroundColor Cyan
}

Write-Host "    To use fonts immediately:" -ForegroundColor White
Write-Host "1. Restart your applications (VS Code, browsers, etc.)" -ForegroundColor Gray
Write-Host "2. Run: gpupdate /force" -ForegroundColor Gray
Write-Host "3. Log off and log back in" -ForegroundColor Gray
Write-Host "4. For system-wide fonts, a reboot may be needed" -ForegroundColor Gray

if ($registeredFonts -eq 0) {
    Write-Host "   No fonts were registered. Possible issues:" -ForegroundColor Red
    Write-Host "   - Fonts may already be properly installed" -ForegroundColor Gray
    Write-Host "   - Try the -ForceReinstall parameter" -ForegroundColor Gray
    Write-Host "   - Check if fonts appear in Font Settings" -ForegroundColor Gray
}
