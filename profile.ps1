# Oh My Posh prompt
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
oh-my-posh init pwsh --config "$HOME\.ohmyposh.omp.json" | Invoke-Expression

# File/folder icons in directory listings
Import-Module Terminal-Icons

# Predictive IntelliSense (grayed-out history suggestions)
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
