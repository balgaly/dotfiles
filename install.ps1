# Run this script on a new PC to set up the terminal environment.
# Prerequisites: Windows Terminal, PowerShell 7, winget
#
# NOTE: --accept-package-agreements auto-accepts third-party EULAs (Oh My Posh, fonts).
# Review the licences at https://ohmyposh.dev before running in a corporate environment.

$ErrorActionPreference = "Stop"

Write-Host "Installing Oh My Posh..." -ForegroundColor Cyan
# winget may return non-zero even on success; only fail on real errors
winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
if ($LASTEXITCODE -notin 0, -1978335189) {
    Write-Error "Oh My Posh install failed (exit $LASTEXITCODE)"
}

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "Installing Nerd Font..." -ForegroundColor Cyan
oh-my-posh font install meslo --headless

Write-Host "Installing PowerShell modules..." -ForegroundColor Cyan
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser

Write-Host "Copying config files..." -ForegroundColor Cyan

Copy-Item "$PSScriptRoot\ohmyposh.omp.json" "$HOME\.ohmyposh.omp.json" -Force

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir | Out-Null }
if (Test-Path $PROFILE) {
    $backup = "$PROFILE.bak"
    Copy-Item $PROFILE $backup -Force
    Write-Host "Existing profile backed up to $backup" -ForegroundColor Yellow
}
Copy-Item "$PSScriptRoot\profile.ps1" $PROFILE -Force

$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path (Split-Path $wtSettingsPath)) {
    Copy-Item "$PSScriptRoot\windows-terminal-settings.json" $wtSettingsPath -Force
    Write-Host "Windows Terminal settings applied." -ForegroundColor Green
} else {
    Write-Host "Windows Terminal not found — skipping settings.json." -ForegroundColor Yellow
}

Write-Host "`nDone! Restart Windows Terminal to see the changes." -ForegroundColor Green
