# WinFig 🛠️✨

A small, battle-tested Windows configuration toolkit to bootstrap a developer-friendly environment on a fresh install.

Highlights:
- Minimal, well-tested PowerShell scripts and settings
- Opinionated defaults for productivity and development

---

## Quick Start

1. Requirements:
	- Windows 10 or 11
	- PowerShell 5.1+ (or newer)
	- Administrator privileges

2. Clone this repo and follow the included setup scripts or instructions in each folder.

Note: This is an initial README — setup details and examples will be expanded over time.

---

## Bootstrap usage

The `bootstrap.ps1` script automates initial machine setup (package managers, Git, repository clone, fonts, and basic dotfiles). Two recommended ways to run it:

- Quick one-liner (convenient):

```powershell
iwr -useb https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1 | iex
```

- Download and inspect first (recommended):

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1 -OutFile .\bootstrap.ps1
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

Important notes:
- The script requires Administrator privileges for installs — open PowerShell as Administrator or let the script re-launch elevated when prompted.
- By default the repo clones into OneDrive Documents (if available) or your local Documents folder. Edit `$Global:RepoPath` in the script to change this.

## Safety & Troubleshooting

- Backup important config files before running. Testing in a VM is recommended.
- If you encounter repeated elevation prompts when using the iwr|iex one-liner, manually run the downloaded script from an elevated PowerShell window.
- If you get parser/encoding errors after download, ensure the file is saved in UTF-8 and hasn't been edited in a way that breaks quoted strings or backtick line continuations.
- If package manager installs fail, install the package manager (winget/choco) manually and re-run the script.

## Recommended workflow

1. Inspect the script locally before running:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Armoghan-ul-Mohmin/Winfig/main/bootstrap.ps1 -OutFile .\bootstrap.ps1
code .\bootstrap.ps1
```

2. Run in a VM first when possible.
3. Execute locally with:

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

4. After completion, open the cloned repo and follow per-project instructions.

---

## Wallpapers
Curated wallpapers live in a separate repo:
[Winfig Wallpapers](https://github.com/Armoghan-ul-Mohmin/Winfig-Wallpapers.git)

---

## Contributing
Contributions are welcome. For small improvements:

1. Fork
2. Create a feature branch
3. Open a pull request

Keep changes small and focused. If you want to propose larger changes, open an issue to discuss first.

---

## License
MIT — see the `LICENSE` file.
