# Copies your live config files back into the dotfiles repo and pushes to GitHub.
# Run this after making any changes to your terminal settings.

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot

Write-Host "Syncing live config files into repo..." -ForegroundColor Cyan

Copy-Item $PROFILE "$repo\profile.ps1" -Force
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" "$repo\windows-terminal-settings.json" -Force

Set-Location $repo
git add profile.ps1 windows-terminal-settings.json themes/ theme-loader.ps1

$status = git status --porcelain
if (-not $status) {
    Write-Host "Nothing changed — repo already up to date." -ForegroundColor Green
    return
}

$msg = Read-Host "Commit message (leave blank for 'Update dotfiles')"
if (-not $msg) { $msg = "Update dotfiles" }

git commit -m $msg
git push origin master
Write-Host "`nDone! Changes pushed to GitHub." -ForegroundColor Green
