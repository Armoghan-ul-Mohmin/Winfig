
# 🚀 Winfig Tools Installer Guide

> **Automate your Windows setup with style!**<br>
> Easily install all your favorite tools and utilities using PowerShell, winget, and choco.<br>
> Packages are managed in simple JSON files for easy customization.

---

## ✨ Features
- Installs essential tools for productivity, development, and customization
- Uses both [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and [choco](https://chocolatey.org/) for maximum coverage
- Skips already installed packages automatically
- Easy to edit package lists in JSON format

---

## 📦 Default Packages & Explanations

### 🟦 Winget Packages
| Package                | Description                                      |
|------------------------|--------------------------------------------------|
| **7zip.7zip**          | Powerful file archiver and extractor             |
| **ShareX.ShareX**      | Screenshot and screen recording tool             |
| **Git.Git**            | Distributed version control system               |
| **SublimeHQ.SublimeText.4** | Fast, lightweight code editor                |
| **Zen-Team.Zen-Browser** | Minimalist privacy-focused web browser         |
| **Nilesoft.Shell**     | Windows shell extension for power users          |
| **Microsoft.PowerToys**| Productivity utilities for Windows               |
| **GoLang.Go**          | Go programming language                         |
| **OpenJS.NodeJS.LTS**  | Node.js JavaScript runtime                      |
| **Microsoft.OneDrive** | Cloud storage and sync                          |
| **Microsoft.VisualStudioCode** | Popular code editor                       |
| **Python.Python.3**    | Python programming language                     |
| **Mozilla.Thunderbird**| Email client                                    |
| **XavierRoche.HTTrack**| Website copier/offline browser                  |
| **GitHub.cli**         | GitHub command-line interface                   |
| **gerardog.gsudo**     | Run commands as administrator                   |
| **Oracle.JDK.21**      | Java Development Kit                            |
| **Google.GoogleDrive** | Google cloud storage                            |
| **OpenVPNTechnologies.OpenVPN** | VPN client                              |
| **Starship.Starship**  | Minimal, blazing-fast shell prompt              |
| **AnyDesk.AnyDesk**    | Remote desktop software                         |
| **Dropbox.Dropbox**    | Cloud storage                                   |
| **Microsoft.PowerShell**| Advanced command-line shell                     |
| **Notion.Notion**      | All-in-one workspace for notes/tasks            |
| **Zoom.Zoom.EXE**      | Video conferencing tool                         |
| **pnpm.pnpm**          | Fast, disk-efficient package manager            |
| **sharkdp.bat**        | Bat: cat clone with syntax highlighting         |
| **namazso.OpenHashTab**| File hash calculator (Explorer extension)       |

### 🟫 Choco Packages
| Package         | Description                                 |
|-----------------|---------------------------------------------|
| **chocolatey**  | The choco package manager itself            |
| **curl**        | Command-line tool for transferring data     |
| **discord**     | Chat for communities and gamers             |
| **fzf**         | Fuzzy finder for your terminal              |
| **hashmyfiles** | File hash calculator utility                |
| **lazygit**     | Simple terminal UI for git                  |
| **onefetch**    | Git repo summary in your terminal           |
| **starship**    | Minimal, blazing-fast shell prompt          |
| **Wget**        | Network downloader utility                  |
| **winfetch**    | System info in your terminal                |
| **winget**      | Windows package manager                     |
| **winget-cli**  | CLI for Windows package manager             |
| **zoxide**      | Smarter cd command for your shell           |

---

## 🛠️ How to Use
1. **Customize your package lists:**<br>
   Edit the JSON files in `Scripts/Assets`:
   - `winget-packages.json` for winget
   - `choco-packages.json` for choco
2. **Run the installer as administrator:**<br>
   ```powershell
   .\Install-Tools.ps1
   ```
3. **Watch the magic happen!**<br>
   The script will install all packages, skipping those already installed.

---

## 🧩 Troubleshooting & Tips
- Make sure you run the script as administrator
- Ensure winget and choco are installed and in your PATH
- If a package fails, check its spelling and availability
- You can add or remove packages by editing the JSON files

---

## 🙏 Credits & Info
Made with ❤️ by **Armoghan-ul-Mohmin** for Winfig
Feel free to contribute or suggest new packages!
