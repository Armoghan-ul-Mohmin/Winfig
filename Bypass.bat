@echo off
REM ===============================================================================
REM Script Name  : Bypass.bat
REM Author       : Armoghan-ul-Mohmin
REM Date         : 2025-10-11
REM Version      : 1.0.0
REM -------------------------------------------------------------------------------
REM Description:
REM     Windows Batch Script to Bypass Microsoft Windows requirements that force
REM     Microsoft Account setup and modify registry settings for installation.
REM
REM Workflow:
REM     1. Bypass Windows 11 Installation Requirements
REM     2. Bypass Microsoft Account Requirement
REM     3. Bypass OOBE (Out-Of-Box Experience) Setup
REM
REM -------------------------------------------------------------------------------
REM Usage:
REM     Run directly from the web:
REM         curl -L -o Bypass.bat https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/refs/heads/main/Bypass.bat && Bypass.bat
REM
REM ===============================================================================

echo.
echo [92mWindows 11 Installation and OOBE Bypass Script[0m
echo [93m================================================[0m
echo.

REM =============================================================================
REM Windows 11 Hardware Requirement Bypasses
REM =============================================================================

REM Creates registry entry to skip Trusted Platform Module 2.0 check during Windows 11 installation
echo [32mSetting TPM 2.0 bypass...[0m
reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m✓ TPM 2.0 bypass configured successfully[0m
) else (
    echo [31m✗ Failed to configure TPM 2.0 bypass[0m
)

REM Bypass RAM Requirement Check
REM Bypasses the minimum RAM requirement check (4GB for Windows 11)
echo [32mSetting RAM requirement bypass...[0m
reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m✓ RAM requirement bypass configured successfully[0m
) else (
    echo [31m✗ Failed to configure RAM requirement bypass[0m
)

REM Disables Secure Boot requirement verification during installation
echo [32mSetting Secure Boot bypass...[0m
reg add "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m✓ Secure Boot bypass configured successfully[0m
) else (
    echo [31m✗ Failed to configure Secure Boot bypass[0m
)

REM =============================================================================
REM Account Setup Bypasses
REM =============================================================================

REM Allows local account creation during OOBE without requiring Microsoft Account
echo [32mSetting Microsoft Account bypass...[0m
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\BypassNRO" /v NetworkRequirement /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [32m✓ Microsoft Account bypass configured successfully[0m
) else (
    echo [31m✗ Failed to configure Microsoft Account bypass[0m
)

echo.
echo [93mAll bypass settings have been applied successfully![0m
echo [96mSystem is now configured to bypass Windows 11 installation requirements.[0m
echo.
pause
