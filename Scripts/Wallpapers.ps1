
# ============================
#   Winfig Wallpapers Setup
# ============================

param(
    [string]$RepoUrl = "https://github.com/Armoghan-ul-Mohmin/Winfig-Wallpapers.git"
)

# Detect Pictures folder (OneDrive or local)
function Get-PicturesFolder {
    $oneDrivePictures = Join-Path $env:USERPROFILE "OneDrive\Pictures"
    $localPictures = Join-Path $env:USERPROFILE "Pictures"
    if (Test-Path $oneDrivePictures) {
        return $oneDrivePictures
    } elseif (Test-Path $localPictures) {
        return $localPictures
    } else {
        Write-Host "ERROR: Pictures folder not found!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "==========================================" -ForegroundColor Gray
Write-Host "   WINFIG WALLPAPERS SETUP" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Gray

$PicturesFolder = Get-PicturesFolder
Write-Host "Pictures folder detected: $PicturesFolder" -ForegroundColor White

$WallpapersFolder = Join-Path $PicturesFolder "Winfig-Wallpapers"

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git is not installed or not in PATH." -ForegroundColor Red
    exit 1
}

# Clone repo if not already present
if (-not (Test-Path $WallpapersFolder)) {
    Write-Host "Cloning wallpapers repo..." -ForegroundColor Cyan
    git clone $RepoUrl $WallpapersFolder
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Wallpapers repo cloned!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to clone repo." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Wallpapers repo already exists at: $WallpapersFolder" -ForegroundColor Yellow
}



# Open Settings app to Personalization > Background
Write-Host "Opening Windows Settings to Personalization > Background..." -ForegroundColor Cyan
Start-Process -FilePath "ms-settings:personalization-background"

# Show message box with instructions
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show(
    "To enable slideshow:\n\n1. In Settings > Personalization > Background, set 'Personalize your background' to 'Slideshow'.\n2. Click 'Browse' and select your wallpapers folder.\n3. Set your desired interval and shuffle options.\n\nYour wallpapers will now rotate automatically!",
    "Manual Slideshow Setup Required",
    'OK',
    'Information'
)

Write-Host "Script completed. You may now close this window." -ForegroundColor Cyan
