# Winfig Wallpapers Setup Guide

## Overview
This guide explains how to use the `Wallpapers.ps1` PowerShell script to quickly set up and use the Winfig wallpapers collection on Windows 11. The script automates cloning the wallpapers repo and helps you configure a desktop slideshow.

---

## Features
- Automatically clones the Winfig wallpapers repository to your Pictures folder
- Opens Windows Settings to the correct page for wallpaper configuration
- Provides clear instructions for enabling slideshow mode

---

## Prerequisites
- Windows 11
- PowerShell 5.1 or newer
- Git installed and available in your PATH
- Administrator privileges recommended

---

## How to Use
1. **Run the Script**
   - Right-click `Wallpapers.ps1` and select "Run with PowerShell".
   - The script will clone the wallpapers repo to your Pictures folder (if not already present).
2. **Configure Slideshow**
   - The script will automatically open Windows Settings > Personalization > Background.
   - A message box will appear with instructions:
     - Set 'Personalize your background' to 'Slideshow'.
     - Click 'Browse' and select your wallpapers folder (e.g., `Winfig-Wallpapers`).
     - Set your desired interval and shuffle options.
   - Your desktop will now rotate through all wallpapers in the selected folder.

---

## Troubleshooting
- If the repo does not clone, ensure Git is installed and available in your PATH.
- If the slideshow does not activate, follow the instructions in the message box to manually set up the slideshow in Settings.
- For best results, use high-resolution images in your wallpapers folder.

---

## Credits
Created by Armoghan-ul-Mohmin

---

## License
See main project LICENSE file.
