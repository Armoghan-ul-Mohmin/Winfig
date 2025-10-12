[CmdletBinding()]
param()

# Initialize counters
$Script:RemovedCount = 0
$Script:NotFoundCount = 0
$Script:ErrorCount = 0

function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )

    $Colors = @{
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error" = "Red"
        "Info" = "Cyan"
    }

    Write-Host $Message -ForegroundColor $Colors[$Type]
}

function Remove-AppSafely {
    param(
        [string]$PackageName,
        [string]$DisplayName
    )

    try {
        $Package = Get-AppxPackage -Name $PackageName -ErrorAction SilentlyContinue

        if ($null -eq $Package) {
            Write-Log "Not found: $DisplayName" "Info"
            $Script:NotFoundCount++
            return
        }

        Write-Host "Removing: $DisplayName..." -NoNewline
        Remove-AppxPackage -Package $Package.PackageFullName -ErrorAction Stop
        Write-Host " [OK]" -ForegroundColor Green
        $Script:RemovedCount++
    }
    catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Log "Error removing $DisplayName" "Error"
        $Script:ErrorCount++
    }
}

# Define apps to remove
$AppsToRemove = @(
    @{packageName="Microsoft.549981C3F5F10"; displayName="Cortana"}
    @{packageName="MicrosoftWindows.Client.WebExperience"; displayName="Widgets"}
    @{packageName="Microsoft.GetHelp"; displayName="Get Help"}
    @{packageName="Microsoft.BingWeather"; displayName="Weather"}
    @{packageName="Microsoft.BingNews"; displayName="News"}
    @{packageName="Microsoft.Todos"; displayName="Microsoft To Do"}
    @{packageName="Microsoft.MicrosoftSolitaireCollection"; displayName="Solitaire Collection"}
    @{packageName="Microsoft.WindowsFeedbackHub"; displayName="Feedback Hub"}
    @{packageName="Microsoft.MicrosoftOfficeHub"; displayName="Office Hub"}
    @{packageName="Microsoft.PowerAutomateDesktop"; displayName="Power Automate Desktop"}
    @{packageName="Microsoft.Microsoft3DViewer"; displayName="3D Viewer"}
    @{packageName="Microsoft.SkypeApp"; displayName="Skype"}
    @{packageName="Microsoft.Getstarted"; displayName="Tips App"}
    @{packageName="Microsoft.Office.OneNote"; displayName="OneNote for Windows 10"}
    @{packageName="Microsoft.MSPaint"; displayName="Paint 3D"}
    @{packageName="Microsoft.MicrosoftStickyNotes"; displayName="Sticky Notes"}
    @{packageName="SpotifyAB.SpotifyMusic"; displayName="Spotify"}
    @{packageName="Disney.37853FC22B2CE"; displayName="Disney+"}
    @{packageName="Microsoft.XboxApp"; displayName="Xbox Console Companion"}
    @{packageName="Microsoft.MixedReality.Portal"; displayName="Mixed Reality Portal"}
    @{packageName="Clipchamp.Clipchamp"; displayName="Clipchamp"}
    @{packageName="MicrosoftCorporationII.QuickAssist"; displayName="Quick Assist"}
    @{packageName="MicrosoftTeams"; displayName="Microsoft Teams (Personal)"}
    @{packageName="MSTeams"; displayName="Microsoft Teams"}
    @{packageName="Microsoft.GamingApp"; displayName="Xbox Gaming App"}
    @{packageName="MicrosoftCorporationII.MicrosoftFamily"; displayName="Microsoft Family"}
    @{packageName="Microsoft.Windows.DevHome"; displayName="Dev Home"}
    @{packageName="Microsoft.OutlookForWindows"; displayName="Outlook (New)"}
    @{packageName="Microsoft.6365217CE6EB4"; displayName="Microsoft Security"}
    @{packageName="Microsoft.WidgetsPlatformRuntime"; displayName="Widgets Platform Runtime"}
    @{packageName="Microsoft.BingSearch"; displayName="Bing Search"}
    @{packageName="Microsoft.StartExperiencesApp"; displayName="Start Experiences App"}
    @{packageName="Microsoft.MicrosoftPCManager"; displayName="Microsoft PC Manager"}
    @{packageName="Microsoft.WindowsCamera"; displayName="Camera"}
    @{packageName="Microsoft.WindowsMaps"; displayName="Maps"}
    @{packageName="Microsoft.WindowsAlarms"; displayName="Alarms & Clock"}
    @{packageName="Microsoft.People"; displayName="People"}
    @{packageName="Microsoft.YourPhone"; displayName="Phone Link"}
    @{packageName="Microsoft.XboxIdentityProvider"; displayName="Xbox Identity Provider"}
    @{packageName="Microsoft.XboxSpeechToTextOverlay"; displayName="Xbox Speech To Text Overlay"}
    @{packageName="Microsoft.XboxGameOverlay"; displayName="Xbox Game Overlay"}
    @{packageName="Microsoft.Xbox.TCUI"; displayName="Xbox Live in-game experience"}
    @{packageName="Facebook.317180B0BB486"; displayName="Instagram"}
    @{packageName="7EE7776C.LinkedInforWindows"; displayName="LinkedIn"}
    @{packageName="Microsoft.WindowsSoundRecorder"; displayName="Voice Recorder"}
    @{packageName="Microsoft.ZuneVideo"; displayName="Movies & TV"}
    @{packageName="Microsoft.ZuneMusic"; displayName="Groove Music"}
    @{packageName="Microsoft.GetStarted"; displayName="Get Started"}
    @{packageName="Microsoft.Wallet"; displayName="Microsoft Pay"}
    @{packageName="Microsoft.OneConnect"; displayName="Mobile Plans"}
    @{packageName="Microsoft.Messaging"; displayName="Microsoft Messaging"}
    @{packageName="Microsoft.WindowsFeedback"; displayName="Feedback Hub"}
    @{packageName="Microsoft.ScreenSketch"; displayName="Snip & Sketch"}
    @{packageName="Microsoft.Windows.ScreenSketch"; displayName="Snipping Tool"}
)

# Main execution
Clear-Host
Write-Log "Windows 11 Debloating Script v1.0.0" "Info"
Write-Log "Starting bloatware removal..." "Info"
Write-Log "Processing $($AppsToRemove.Count) applications..." "Info"

# Process each app
foreach ($App in $AppsToRemove) {
    Remove-AppSafely -PackageName $App.packageName -DisplayName $App.displayName
}

# Show summary
Write-Log "" "Info"
Write-Log "=== SUMMARY ===" "Info"
Write-Log "Applications processed: $($AppsToRemove.Count)" "Info"
Write-Log "Successfully removed: $Script:RemovedCount" "Success"
Write-Log "Not found: $Script:NotFoundCount" "Info"
Write-Log "Errors: $Script:ErrorCount" $(if ($Script:ErrorCount -gt 0) { "Error" } else { "Info" })
Write-Log "" "Info"
Write-Log "Debloating complete!" "Success"

# Registry Configuration Function
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord",
        [string]$Description
    )

    try {
        # Create registry key if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        Write-Host "Setting: $Description..." -NoNewline
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        Write-Host " [OK]" -ForegroundColor Green
    }
    catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Log "Failed to set $Description" "Error"
    }
}

# Registry Optimizations
Write-Log "" "Info"
Write-Log "=== REGISTRY OPTIMIZATIONS ===" "Info"
Write-Log "Applying Windows registry optimizations..." "Info"

# Theme and Appearance Settings
Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Description "Enable Dark Mode for Apps"
Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Description "Enable Dark Mode for System"

# Search and Taskbar Settings
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Description "Disable Bing Search in Start Menu"
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1 -Description "Show Search Icon in Taskbar"

# System and Boot Settings
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Value 1 -Description "Enable Verbose Boot Messages"

# Start Menu Recommendations
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "HideRecommendedSection" -Value 1 -Description "Hide Recommended Section in Start Menu"
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecommendedSection" -Value 1 -Description "Hide Recommended Files in Explorer"

# Education Environment
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Education" -Name "IsEducationEnvironment" -Value 0 -Description "Disable Education Environment Features"

# Mouse Settings for Enhanced Precision
Set-RegistryValue -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value 1 -Description "Enable Enhanced Pointer Precision"
Set-RegistryValue -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value 6 -Description "Set Mouse Acceleration Threshold 1"
Set-RegistryValue -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value 10 -Description "Set Mouse Acceleration Threshold 2"

# Accessibility Settings
Set-RegistryValue -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value 510 -Description "Disable Sticky Keys Notifications"

# File Explorer Settings
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Description "Show Hidden Files and Folders"
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Description "Show File Extensions"

# Taskbar Settings
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Description "Hide Task View Button"
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Description "Hide Widgets from Taskbar"

# System Crash Settings
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DisplayParameters" -Value 1 -Description "Show Crash Details on BSOD"
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DisableEmoticon" -Value 1 -Description "Disable Sad Face on BSOD"

Write-Log "Registry optimizations completed!" "Success"

# Restart Explorer to apply changes
Write-Log "Restarting Windows Explorer to apply changes..." "Info"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Log "Explorer restarted successfully" "Success"
}
catch {
    Write-Log "Explorer restart may be required manually" "Warning"
}

# Ask user about Chris Titus Tech Winutil
Write-Log "" "Info"
Write-Log "=== ADDITIONAL CONFIGURATION ===" "Info"
Write-Log "Would you like to run Chris Titus Tech's Windows Utility for additional system optimization?" "Info"
Write-Host "This will download a preset configuration and launch the Winutil tool." -ForegroundColor Yellow

$RunWinutil = Read-Host "Run Chris Titus Tech Winutil? (Y/N)"

if ($RunWinutil -match '^[Yy]') {
    Write-Log "Preparing Chris Titus Tech Winutil..." "Info"

    try {
        # Get Desktop path
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $PresetPath = Join-Path $DesktopPath "Winutil.json"

        Write-Log "Downloading preset configuration to Desktop..." "Info"

        # Download preset configuration
        $PresetUrl = "https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/config/Winutil.json"
        Invoke-WebRequest -Uri $PresetUrl -OutFile $PresetPath -ErrorAction Stop

        Write-Log "Preset configuration downloaded: $PresetPath" "Success"
        Write-Log "" "Info"
        Write-Log "IMPORTANT INSTRUCTIONS:" "Warning"
        Write-Log "1. Winutil will open in a new window" "Info"
        Write-Log "2. Your preset configuration is saved on Desktop as 'Winutil.json'" "Info"
        Write-Log "3. In Winutil, click 'Import' and select the Winutil.json file from Desktop" "Info"
        Write-Log "4. This will apply your custom optimization settings" "Info"
        Write-Log "" "Info"

        $Continue = Read-Host "Press Enter to launch Winutil or 'Q' to quit"

        if ($Continue -notmatch '^[Qq]') {
            Write-Log "Launching Chris Titus Tech Winutil..." "Info"
            Write-Log "Please wait while Winutil loads..." "Info"

            # Launch Winutil
            Invoke-Expression "iwr -useb https://christitus.com/win | iex"
        }
        else {
            Write-Log "Winutil launch cancelled. Preset file is available on Desktop." "Info"
        }
    }
    catch {
        Write-Log "Failed to download preset configuration: $($_.Exception.Message)" "Error"
        Write-Log "You can manually download it from: https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/config/Winutil.json" "Info"

        $LaunchAnyway = Read-Host "Launch Winutil anyway? (Y/N)"
        if ($LaunchAnyway -match '^[Yy]') {
            Write-Log "Launching Chris Titus Tech Winutil..." "Info"
            Invoke-Expression "iwr -useb https://christitus.com/win | iex"
        }
    }
}
else {
    Write-Log "Skipping Winutil. Script execution complete." "Info"
}

# Ask User About Running Winfig Bootstrap
Write-Log "" "Info"
Write-Log "Would you like to run the Winfig Bootstrap script for additional system optimization?" "Info"
$RunWinfig = Read-Host "Run Winfig Bootstrap? (Y/N)"

if ($RunWinfig -match '^[Yy]') {
    Write-Log "Launching Winfig Bootstrap..." "Info"
    Write-Log "Please wait while Winfig Bootstrap loads..." "Info"
    try {
        Invoke-Expression "iwr -useb https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1 | iex"
    }
    catch {
        Write-Log "Failed to launch Winfig Bootstrap: $($_.Exception.Message)" "Error"
        Write-Log "You can manually run it from: https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1" "Info"
    }
}
else {
    Write-Log "Skipping Winfig Bootstrap. Script execution complete." "Info"
}

Write-Log "" "Info"
Write-Log "Thank you for using the Windows 11 Debloating Script!" "Success"

