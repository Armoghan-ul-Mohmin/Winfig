<h1 align="center"> Winfig </h1>

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg?style=for-the-badge)](https://github.com/PowerShell/PowerShell)
[![Chocolatey Compatible](https://img.shields.io/badge/Compatible%20with-Chocolatey-ff69b4.svg?style=for-the-badge)](https://chocolatey.org/)
[![Winget Compatible](https://img.shields.io/badge/Compatible%20with-Winget-228B22.svg?style=for-the-badge)](https://github.com/microsoft/winget-cli)
[![Windows](https://img.shields.io/badge/Windows-10%2B-0078d4.svg?style=for-the-badge)](https://www.microsoft.com/windows)

[![Issues](https://img.shields.io/github/issues/Armoghan-ul-Mohmin/Winfig.svg?style=flat-square)](https://github.com/Armoghan-ul-Mohmin/Winfig.git/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/Armoghan-ul-Mohmin/Winfig.svg?style=flat-square)](https://github.com/Armoghan-ul-Mohmin/Winfig.git/pulls)
[![Repo Size](https://img.shields.io/github/repo-size/Armoghan-ul-Mohmin/Winfig?style=flat-square)](https://github.com/Armoghan-ul-Mohmin/Winfig.git)
[![Last Commit](https://img.shields.io/github/last-commit/Armoghan-ul-Mohmin/Winfig?style=flat-square)](https://github.com/Armoghan-ul-Mohmin/Winfig.git/commits/main)

</div>

A comprehensive Windows configuration toolkit designed to streamline Windows 11 installations and create a developer-friendly environment on fresh installs.

## Table of Contents
- [Features](#features)
- [Windows 11 Installation Bypass](#windows-11-installation-bypass)
  - [Quick Installation Guide](#quick-installation-guide)
    - [Registry Method](#registry-method)
- [Troubleshooting Failed Installations](#troubleshooting-failed-installations)
- [Contributing](#contributing)
  - [Development Workflow](#development-workflow)
  - [Contribution Standards](#contribution-standards)
- [Disclaimer](#disclaimer)
- [License](#license)

## Features
- **Hardware Requirement Bypass**: Disable TPM 2.0, RAM, and Secure Boot checks
- **OOBE Customization**: Bypass Out-Of-Box Experience restrictions
- **Local Account Creation**: Enable local account setup without Microsoft Account
- **Windows Configuration**: Automate system settings for optimal performance

## Windows 11 Installation Bypass

### Quick Installation Guide

Follow these steps during Windows 11 installation to bypass system requirements:

#### Registry Method

1. **Boot from Windows 11 Install Media**
   - Boot off your Windows 11 installation disk
   - The first screen should ask you to choose the installation language

   ![Windows 11 Install Language](img/1.png)

2. **Open Command Prompt**
   - Press `Shift + F10` to open a command prompt window during setup

   ![Command Prompt](img/2.png)

3. **Execute Registry Commands**
   - Copy and paste the following commands **one by one** in the command prompt:

   Bypass TPM 2.0 Requirement
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /t REG_DWORD /d 1 /f
   ```
   Bypass RAM Requirement Check
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /t REG_DWORD /d 1 /f
    ```
   Bypass Secure Boot Check
   ```batch
   reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
    ```
    Bypass Microsoft Account Requirement
    ```batch
   reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\BypassNRO" /v NetworkRequirement /t REG_DWORD /d 0 /f
   ```

   ![Registry Commands](img/3.png)

4. **Complete Installation**
   - All bypass settings are now configured
   - Continue with the Windows 11 installation normally
   - You can now create a local account without Microsoft Account requirements

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

## Disclaimer

⚠️ **Disclaimer**: Modifying your system registry can have unintended consequences—proceed at your own risk and ensure you understand the potential impact on your system.

## License

This project is distributed under the [**MIT License**](LICENSE) © 2025 Armoghan-ul-Mohmin
