# dotfiles

> Windows Terminal setup with a custom prompt, file icons, predictive IntelliSense, and acrylic transparency.

![Terminal Preview](screenshots/preview.png)

---

## Stack

| Tool | Purpose |
|---|---|
| [Oh My Posh](https://ohmyposh.dev) | Custom prompt engine |
| [MesloLGLDZ Nerd Font](https://www.nerdfonts.com) | Font with developer icons |
| [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) | File & folder icons in `ls` |
| [PSReadLine](https://github.com/PowerShell/PSReadLine) | History-based IntelliSense |

---

## Prompt breakdown

**Left side**

| Segment | Color | Shows |
|---|---|---|
| `pwsh` | Blue | Current shell |
| `→ 🏠` / folder name | Orange | Working directory (`🏠` = home) |
| `⊡ 1.2s` | Purple | Last command execution time |
| Branch + status | Yellow | Git branch, dirty/ahead/behind state (git repos only) |

**Right side**

| Segment | Shows |
|---|---|
| Windows logo | OS indicator |
| `Thu 01 May 10:18` | Day · date · month · time |

The `>>` input line turns **red** on a non-zero exit code.

---

## Prerequisites

- [Windows Terminal](https://aka.ms/terminal)
- [PowerShell 7+](https://aka.ms/powershell)
- winget (included with Windows 10 1809+ / Windows 11)

---

## Install

```powershell
# 1. Install git if you don't have it
winget install Git.Git --accept-package-agreements --accept-source-agreements

# 2. Clone and run
git clone https://github.com/balgaly/dotfiles
cd dotfiles
.\install.ps1

# 3. Restart Windows Terminal
```

The script installs Oh My Posh, the Nerd Font, and Terminal-Icons, then copies all config files to the right locations automatically.

---

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+W` | Close pane |
| `Alt+Shift+D` | Split pane |
| `Tab` | Menu autocomplete |
| `↑` / `↓` | Search command history |

---

## Customization

**Swap the prompt theme** — browse at [ohmyposh.dev/docs/themes](https://ohmyposh.dev/docs/themes):

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/THEME.omp.json" -OutFile "$HOME\.ohmyposh.omp.json"
```

**Change the date format** — edit `ohmyposh.omp.json`, find `time_format`. Uses Go time syntax:

```
Mon 02 Jan 15:04   →   Thu 01 May 10:18
```

**Adjust transparency** — edit `windows-terminal-settings.json`:

```json
"opacity": 85,
"useAcrylic": true
```
