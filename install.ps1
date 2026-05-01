# Run this script on a new PC to set up the terminal environment.
# Prerequisites: Windows Terminal, PowerShell 7, winget

$ErrorActionPreference = "Stop"

Write-Host "Installing Oh My Posh..." -ForegroundColor Cyan
winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")

Write-Host "Installing Nerd Font..." -ForegroundColor Cyan
oh-my-posh font install meslo --headless

Write-Host "Installing PowerShell modules..." -ForegroundColor Cyan
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser

Write-Host "Copying config files..." -ForegroundColor Cyan
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Copy-Item "$scriptDir\ohmyposh.omp.json" "$HOME\.ohmyposh.omp.json" -Force

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir | Out-Null }
Copy-Item "$scriptDir\profile.ps1" $PROFILE -Force

$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path (Split-Path $wtSettingsPath)) {
    Copy-Item "$scriptDir\windows-terminal-settings.json" $wtSettingsPath -Force
    Write-Host "Windows Terminal settings applied." -ForegroundColor Green
} else {
    Write-Host "Windows Terminal not found — skipping settings.json." -ForegroundColor Yellow
}

Write-Host "`nDone! Restart Windows Terminal to see the changes." -ForegroundColor Green
