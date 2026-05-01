# Oh My Posh prompt
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    # Refresh PATH in case oh-my-posh was just installed in this session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH","User")
}
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$HOME\.ohmyposh.omp.json")))
}

# File/folder icons in directory listings
if (Get-Module -ListAvailable Terminal-Icons -ErrorAction SilentlyContinue) {
    Import-Module Terminal-Icons
}

# Predictive IntelliSense (grayed-out history suggestions)
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
