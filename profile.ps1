# Refresh PATH if oh-my-posh isn't found yet (first run after install)
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH","User")
}

# Load the theme rotator and initialize whichever theme this slot called for.
# The repo lives wherever you cloned it; default = ~/dotfiles
$dotfilesRoot = if ($env:DOTFILES_ROOT) { $env:DOTFILES_ROOT } else { "$HOME\dotfiles" }
$themeLoader  = Join-Path $dotfilesRoot 'theme-loader.ps1'
if (Test-Path $themeLoader) {
    . $themeLoader
    Initialize-Theme
}

# File/folder icons in directory listings
if (Test-Path "$HOME\Documents\PowerShell\Modules\Terminal-Icons") {
    Import-Module Terminal-Icons
}

# Predictive IntelliSense (grayed-out history suggestions)
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
