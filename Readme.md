<div align="center">

# 🔧 Winfig

**The Ultimate Windows 11 Configuration Toolkit**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207.x-5391FE?style=for-the-badge&logo=powershell)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-11-0078d4.svg?style=for-the-badge&logo=windows)](https://www.microsoft.com/windows)
[![Debloat](https://img.shields.io/badge/Removes-52%2B%20Apps-red?style=for-the-badge)](https://github.com/Armoghan-ul-Mohmin/Winfig)

[![GitHub Issues](https://img.shields.io/github/issues/Armoghan-ul-Mohmin/Winfig?style=flat-square&logo=github)](https://github.com/Armoghan-ul-Mohmin/Winfig/issues)
[![GitHub Stars](https://img.shields.io/github/stars/Armoghan-ul-Mohmin/Winfig?style=flat-square&logo=github)](https://github.com/Armoghan-ul-Mohmin/Winfig/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Armoghan-ul-Mohmin/Winfig?style=flat-square&logo=github)](https://github.com/Armoghan-ul-Mohmin/Winfig/network/members)
[![Last Commit](https://img.shields.io/github/last-commit/Armoghan-ul-Mohmin/Winfig?style=flat-square&logo=github)](https://github.com/Armoghan-ul-Mohmin/Winfig/commits/main)

---

**Streamline Windows 11 installations and create a clean, developer-friendly environment**

*Bypass installation requirements • Remove bloatware • Optimize system performance • Integrate advanced tools*

</div>

## Table of Contents
- [Features](#features)
- [Windows 11 Installation Bypass](#windows-11-installation-bypass)
  - [Quick Installation Guide](#quick-installation-guide)
    - [Registry Method](#registry-method)
- [Windows 11 Debloating Script](#windows-11-debloating-script)
  - [Debloat Features](#debloat-features)
  - [Registry Optimizations](#registry-optimizations)
  - [Winutil Integration](#winutil-integration)
  - [Usage Examples](#usage-examples)
- [Troubleshooting Failed Installations](#troubleshooting-failed-installations)
- [Contributing](#contributing)
  - [Development Workflow](#development-workflow)
  - [Contribution Standards](#contribution-standards)
- [Disclaimer](#disclaimer)
- [License](#license)

## ⭐ Key Features

<table>
<tr>
<td width="50%">

### 🚀 Installation Tools
- **Hardware Bypass** - Skip TPM 2.0, RAM, and Secure Boot checks
- **Account Freedom** - Create local accounts without Microsoft Account
- **OOBE Customization** - Bypass Out-Of-Box Experience restrictions

### 🧹 System Cleanup
- **52+ App Removal** - Comprehensive bloatware elimination
- **Safe Execution** - Only removes existing applications
- **Error Handling** - Graceful failure recovery

</td>
<td width="50%">

### ⚙️ System Optimization
- **15+ Registry Tweaks** - Performance and privacy enhancements
- **Dark Mode Setup** - System-wide theme configuration
- **Explorer Enhancements** - Show hidden files and extensions

### 🔧 Advanced Integration
- **Winutil Support** - Chris Titus Tech tool integration
- **Custom Presets** - Pre-configured optimization profiles
- **Cross-Version Compatible** - PowerShell 5.1 and 7.x support

</td>
</tr>
</table>

## 🖥️ Windows 11 Installation Bypass

> **Bypass hardware requirements during Windows 11 installation**

<div align="center">

| Step | Action | Result |
|------|--------|---------|
| 1️⃣ | Boot from installation media | Language selection screen |
| 2️⃣ | Press `Shift + F10` | Command prompt opens |
| 3️⃣ | Execute registry commands | Bypass requirements set |
| 4️⃣ | Continue installation | Local account available |

</div>

### 📋 Quick Installation Guide

Follow these steps during Windows 11 installation to bypass system requirements:

#### 🔧 Registry Method

1. **Boot from Windows 11 Install Media**
   - Boot off your Windows 11 installation disk
   - The first screen should ask you to choose the installation language

   ![Windows 11 Install Language](img/1.png)

2. **Open Command Prompt**
   - Press `Shift + F10` to open a command prompt window during setup

   ![Command Prompt](img/2.png)

3. **Execute Registry Commands**

   Copy and paste the following commands **one by one** in the command prompt:

   <details>
   <summary><strong>📋 Individual Commands (Click to expand)</strong></summary>

   **Bypass TPM 2.0 Requirement**
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /t REG_DWORD /d 1 /f
   ```

   **Bypass RAM Requirement Check**
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /t REG_DWORD /d 1 /f
   ```

   **Bypass Secure Boot Check**
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
   ```

   **Bypass Microsoft Account Requirement**
   ```batch
   reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\BypassNRO" /v NetworkRequirement /t REG_DWORD /d 0 /f
   ```
   </details>

   **🚀 One-Line Command (Recommended)**
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /t REG_DWORD /d 1 /f && reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /t REG_DWORD /d 1 /f && reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /t REG_DWORD /d 1 /f && reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\BypassNRO" /v NetworkRequirement /t REG_DWORD /d 0 /f
   ```

   ![Registry Commands](img/3.png)

4. **Complete Installation**
   - All bypass settings are now configured
   - Continue with the Windows 11 installation normally
   - You can now create a local account without Microsoft Account requirements

## 🧹 Windows 11 Debloating Script

> **Transform your fresh Windows 11 installation into a clean, optimized system**

<div align="center">

**🎯 One Script • Three Functions • Complete Solution**

| Component | Description | Impact |
|-----------|-------------|---------|
| **Debloater** | Removes 52+ unwanted apps | Clean system |
| **Registry Optimizer** | Applies 15+ performance tweaks | Enhanced speed |
| **Winutil Integrator** | Launches advanced configuration | Professional setup |

</div>

### 🚀 Quick Start

```powershell
# Run directly from web (Recommended)
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/Debloat.ps1" | Invoke-Expression

# Or download and run locally
.\Debloat.ps1
```

### 📱 Debloat Features

<details>
<summary><strong>🎯 52+ Applications Removed (Click to expand)</strong></summary>

<table>
<tr>
<td width="50%">

**Social Media & Third-Party**
- Instagram
- LinkedIn
- Spotify
- Disney+
- Facebook integrations

**Microsoft Entertainment**
- Xbox Gaming Suite
- Xbox Console Companion
- Xbox Game Overlay
- Solitaire Collection
- Movies & TV

**Productivity Bloat**
- Microsoft Teams (Personal)
- Skype
- Clipchamp
- Paint 3D
- 3D Viewer

</td>
<td width="50%">

**System Apps**
- Cortana
- Widgets
- Voice Recorder
- Snipping Tool
- Camera
- Maps
- Alarms & Clock

**Microsoft Services**
- Weather
- News
- Get Help
- Feedback Hub
- Tips App
- Sticky Notes

**Developer Tools**
- Power Automate Desktop
- Dev Home
- Mixed Reality Portal
- Quick Assist

</td>
</tr>
</table>

</details>

### ⚙️ Registry Optimizations

<div align="center">

**🎛️ 15+ Performance & Privacy Tweaks**

</div>

<table>
<tr>
<td width="33%">

**🎨 Theme & Interface**
- Dark Mode (System-wide)
- Hide Task View Button
- Hide Widgets Button
- Show File Extensions
- Show Hidden Files

</td>
<td width="33%">

**🔒 Privacy & Search**
- Disable Bing Search
- Hide Recommendations
- Remove Telemetry
- Location Tracking Off
- Disable Activity History

</td>
<td width="34%">

**🚀 Performance & System**
- Verbose Boot Messages
- Enhanced Mouse Precision
- Sticky Keys Disabled
- BSOD Technical Details
- Explorer Optimizations

</td>
</tr>
</table>

### 🔧 Winutil Integration

<div align="center">

**🤝 Seamless Integration with Chris Titus Tech's Windows Utility**

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Auto Download** | Fetches custom preset configuration | No manual setup |
| **Desktop Placement** | Saves `Winutil.json` for easy access | Quick import |
| **Guided Setup** | Clear instructions for importing presets | User-friendly |
| **One-Click Launch** | Automatically opens Winutil tool | Effortless transition |

</div>

<details>
<summary><strong>📋 Preset Configuration Features</strong></summary>

- **System Tweaks**: Advanced registry optimizations
- **Service Management**: Optimized Windows services
- **Privacy Enhancements**: Comprehensive telemetry blocking
- **Performance Tweaks**: CPU and memory optimizations
- **Security Hardening**: Enhanced system protection
- **Network Optimization**: Improved connectivity settings

</details>

### 💻 Usage Examples

<div align="center">

**Choose Your Preferred Execution Method**

</div>

#### 🌐 Method 1: Direct Web Execution (Recommended)
```powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/Debloat.ps1" | Invoke-Expression
```
> **Advantages**: Always gets the latest version • No manual downloads • Single command execution

#### 📁 Method 2: Local Download & Execute
```powershell
# Download the script first
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/Debloat.ps1" -OutFile "Debloat.ps1"

# Then execute locally
.\Debloat.ps1
```
> **Advantages**: Offline execution • Script inspection before running • Version control

### 🛡️ Safety Features

<div align="center">

| Safety Measure | Description | Protection Level |
|----------------|-------------|------------------|
| **Existence Check** | Only removes apps if installed | 🟢 High |
| **Error Handling** | Graceful failure recovery | 🟢 High |
| **Progress Feedback** | Real-time status updates | 🟡 Medium |
| **Compatibility** | PowerShell 5.1 and 7.x support | 🟢 High |
| **Registry Validation** | Safe registry key creation | 🟢 High |

</div>

## Troubleshooting Failed Installations
If Windows 11 installation fails due to hardware requirements:
1. Restart the installation process
2. Press `Shift + F10` as soon as the language selection appears
3. Execute the registry commands before proceeding with installation
4. Continue with the installation

## Contributing

Professional contributions are welcomed from the development community.

### Development Workflow

1. **Repository Fork** - Create independent development branch
2. **Feature Development** - Implement changes in isolated branch (`git checkout -b feature/enhancement`)
3. **Code Commitment** - Document changes with descriptive commit messages
4. **Branch Publication** - Push feature branch to forked repository
5. **Pull Request Submission** - Submit formal code review request

### Contribution Standards

- **Issue Reporting** - Utilize standardized issue templates for consistency
- **Enhancement Proposals** - Engage in architectural discussions prior to implementation
- **Documentation** - Maintain comprehensive documentation standards
- **Quality Assurance** - Implement comprehensive testing for new functionality

## ⚠️ Disclaimer

> **Important Notice**: This toolkit modifies Windows registry settings and removes system applications. While designed with safety measures, please ensure you understand the changes being made. Always create a system restore point before running the scripts.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

<div align="center">

### 🌟 Support the Project

If this toolkit helped you create a cleaner Windows installation, consider:

[![GitHub Stars](https://img.shields.io/github/stars/Armoghan-ul-Mohmin/Winfig?style=social)](https://github.com/Armoghan-ul-Mohmin/Winfig/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/Armoghan-ul-Mohmin/Winfig?style=social)](https://github.com/Armoghan-ul-Mohmin/Winfig/fork)

**Made with ❤️ by [Armoghan-ul-Mohmin](https://github.com/Armoghan-ul-Mohmin)**

*Empowering users to take control of their Windows experience*

---

**© 2025 Winfig Project • All Rights Reserved**

</div>
