# Fonts Installation Guide

This document explains how to use the `Install-Fonts.ps1` helper script that ships
with Winfig. The script automates extracting font ZIPs and registering fonts for
per-user or system-wide use.

## Location

Script: `Scripts/Install-Fonts.ps1`

Default asset folder: `Scripts/Assets/` (the script looks there by default)

## Purpose

- Extract font ZIP archives (containing `.ttf`, `.otf`, or `.ttc` files)
- Copy fonts to the appropriate folder (per-user or system-wide)
- Register font names in the registry so Windows recognizes them
- Attempt several methods to refresh the font cache so fonts become usable

## Parameters

- `-FontZips <string[]>` (optional)
  - An array of ZIP file names found inside the `SourceFolder` (default: `@("Hack.zip","JetBrainsMono.zip")`).
  - You can pass custom ZIP file names or a full path when calling the script.

- `-SourceFolder <string>` (optional)
  - Path to the folder that contains the font ZIP files. Default: `Scripts/Assets` (relative to the script).
  - Example: `-SourceFolder 'C:\repos\winfig\Scripts\Assets'`

- `-SystemWide` (switch)
  - When specified, fonts are copied to `C:\Windows\Fonts` and registry entries are written to `HKLM`.
  - Requires Administrator privileges. The script will fail early if not elevated.

- `-ForceReinstall` (switch)
  - When specified, font files are copied and registry entries are re-written even if the font files already exist.

## Examples

- Per-user install (default behavior with explicit folder):

```powershell
pwsh -NoProfile -File .\Scripts\Install-Fonts.ps1 -SourceFolder .\Scripts\Assets
```

- System-wide install (requires running as Administrator):

```powershell
Start-Process pwsh -Verb runAs -ArgumentList '-NoProfile','-File','f:\Github\Armoghan-ul-Mohmin\winfig\Scripts\Install-Fonts.ps1','-SystemWide'
```

- Force reinstall fonts even if files exist:

```powershell
pwsh -NoProfile -File .\Scripts\Install-Fonts.ps1 -ForceReinstall
```

## What the script does (high level)

1. Validates the provided ZIP files exist in `SourceFolder`.
2. Extracts each ZIP to a temporary folder.
3. Locates font files (`.ttf`, `.otf`, `.ttc`) and copies them to the destination font folder.
4. Writes registry entries under the appropriate hive (`HKCU` or `HKLM`).
5. Attempts to refresh the font cache using multiple techniques.
6. Prints a summary with counts of processed and registered fonts.

## Troubleshooting

- Missing ZIPs: ensure the ZIP filenames provided in `-FontZips` match files in `SourceFolder`.
- Permission errors: for `-SystemWide`, run an elevated PowerShell session.
- Fonts not visible: restart applications, run `gpupdate /force`, log out/in, or reboot for system-wide fonts.
- Font cache issues: on some systems the font cache may need manual intervention — try restarting Explorer or rebooting.

## Logging and undo

- The script currently prints actions to the console. If you need an undo log or CSV of installed files, I can add a `-LogFile` parameter that records `OriginalPath,InstalledPath,RegistryName` for each installed font.

## Safety notes

- Inspect the ZIP contents before running the installer if you are unsure of the source.
- Prefer a per-user install during testing to avoid system-wide changes.

---
