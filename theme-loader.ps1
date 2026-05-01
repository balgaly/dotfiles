# Selects an Oh My Posh theme based on time of day, with manual override.
#
# - Daytime (06:00–17:59) -> random light theme
# - Evening (18:00–05:59) -> random dark theme
# - The choice is locked into a "slot" (morning / evening of a given date),
#   so the theme only changes twice a day, not on every new shell.
# - Override anytime with: Set-Theme <name>   (use Set-Theme list to see them)
#                          Set-Theme random   (re-roll within current slot)
#                          Set-Theme auto     (clear override)

$script:ThemesDir   = Join-Path $PSScriptRoot 'themes'
$script:StateFile   = Join-Path $HOME '.terminal-theme'

$script:LightThemes = @('04-notebook', '05-material-light', '08-pastel-dream', '11-origami')
$script:DarkThemes  = @('01-brutalist', '02-synthwave', '03-tokyo-night', '06-cyberpunk',
                        '07-forest-druid', '09-vt100', '10-glassmorphism', '12-matrix')

function Get-CurrentSlot {
    $now = Get-Date
    $slot = if ($now.Hour -ge 6 -and $now.Hour -lt 18) { 'morning' } else { 'evening' }
    # Evening that starts before midnight stays "evening of date X" until 06:00 next day
    $slotDate = if ($slot -eq 'evening' -and $now.Hour -lt 6) {
        $now.AddDays(-1).ToString('yyyy-MM-dd')
    } else {
        $now.ToString('yyyy-MM-dd')
    }
    "$slotDate-$slot"
}

function Get-PoolForCurrentSlot {
    $now = Get-Date
    if ($now.Hour -ge 6 -and $now.Hour -lt 18) { $script:LightThemes } else { $script:DarkThemes }
}

function Read-State {
    if (-not (Test-Path $script:StateFile)) { return @{} }
    try { Get-Content $script:StateFile -Raw | ConvertFrom-Json -AsHashtable } catch { @{} }
}

function Write-State($state) {
    $state | ConvertTo-Json | Set-Content $script:StateFile
}

function Resolve-ThemeForThisShell {
    $state = Read-State

    # Manual override wins
    if ($state.override) {
        return $state.override
    }

    # Otherwise: roll a fresh theme on every shell open, from the current
    # time-of-day pool. Avoid picking the same one twice in a row.
    $pool = Get-PoolForCurrentSlot
    if ($state.theme -and $pool.Count -gt 1) {
        $pool = $pool | Where-Object { $_ -ne $state.theme }
    }
    $pick = $pool | Get-Random
    Write-State @{ theme = $pick }
    $pick
}

function Get-ThemePath($name) {
    $path = Join-Path $script:ThemesDir "$name.omp.json"
    if (Test-Path $path) { $path } else { $null }
}

function Set-Theme {
    [CmdletBinding()]
    param([Parameter(Position=0)][string]$Name)

    if (-not $Name -or $Name -eq 'list') {
        Write-Host "`nLight themes (used 06:00–17:59):" -ForegroundColor Yellow
        $script:LightThemes | ForEach-Object { Write-Host "  $_" }
        Write-Host "`nDark themes (used 18:00–05:59):" -ForegroundColor Cyan
        $script:DarkThemes  | ForEach-Object { Write-Host "  $_" }
        Write-Host "`nUsage:" -ForegroundColor Gray
        Write-Host "  Set-Theme <name>   pin a specific theme"
        Write-Host "  Set-Theme random   re-roll within current slot"
        Write-Host "  Set-Theme auto     clear pin, return to time-based rotation`n"
        return
    }

    $state = Read-State

    switch ($Name) {
        'auto'   { $state.Remove('override') | Out-Null ; Write-Host "Auto-rotation re-enabled." -ForegroundColor Green }
        'random' {
            $state.Remove('override') | Out-Null
            $pick = (Get-PoolForCurrentSlot) | Get-Random
            $state.theme = $pick
            Write-Host "Rolled: $pick" -ForegroundColor Green
        }
        default {
            if (-not (Get-ThemePath $Name)) {
                Write-Host "Unknown theme: $Name. Try 'Set-Theme list'." -ForegroundColor Red
                return
            }
            $state.override = $Name
            Write-Host "Pinned: $Name. Open a new shell to see it." -ForegroundColor Green
        }
    }

    Write-State $state
    Write-Host "(Restart your shell or run . `$PROFILE to apply.)" -ForegroundColor Gray
}

function Initialize-Theme {
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) { return }
    $name = Resolve-ThemeForThisShell
    $path = Get-ThemePath $name
    if (-not $path) {
        Write-Warning "Theme '$name' not found in $script:ThemesDir"
        return
    }
    & ([ScriptBlock]::Create((oh-my-posh init pwsh --config $path)))
}
