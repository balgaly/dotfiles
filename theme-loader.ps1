# Selects an Oh My Posh theme on every new shell.
#
# - 06:00–17:59 -> a random light theme
# - 18:00–05:59 -> a random dark theme
# - Never picks the same theme twice in a row
# - Override anytime with: Set-Theme <name>   (Set-Theme list to see them)
#                          Set-Theme auto     (clear pin)

$script:ThemesDir   = Join-Path $PSScriptRoot 'themes'
$script:StateFile   = Join-Path $HOME '.terminal-theme'

$script:LightThemes = @('04-notebook', '05-material-light', '08-pastel-dream', '11-origami')
$script:DarkThemes  = @('01-brutalist', '02-synthwave', '03-tokyo-night', '06-cyberpunk',
                        '07-forest-druid', '09-vt100', '10-glassmorphism', '12-matrix')

function Get-PoolForCurrentSlot {
    $h = (Get-Date).Hour
    if ($h -ge 6 -and $h -lt 18) { $script:LightThemes } else { $script:DarkThemes }
}

function Read-State {
    if (-not (Test-Path $script:StateFile)) { return @{} }
    try { Get-Content $script:StateFile -Raw | ConvertFrom-Json -AsHashtable } catch { @{} }
}

function Write-State($state) {
    # Profile must never throw — a locked/full disk shouldn't break shell startup
    try { $state | ConvertTo-Json | Set-Content $script:StateFile -ErrorAction Stop } catch { }
}

function Resolve-ThemeForThisShell {
    $state = Read-State

    if ($state.override) { return $state.override }

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
        Write-Host "  Set-Theme auto     clear pin, return to random rotation`n"
        return
    }

    $state = Read-State

    if ($Name -eq 'auto') {
        $state.Remove('override') | Out-Null
        Write-State $state
        Write-Host "Auto-rotation re-enabled. Open a new tab to roll a fresh theme." -ForegroundColor Green
        return
    }

    if (-not (Get-ThemePath $Name)) {
        Write-Host "Unknown theme: $Name. Try 'Set-Theme list'." -ForegroundColor Red
        return
    }

    $state.override = $Name
    Write-State $state
    Write-Host "Pinned: $Name. Open a new tab to see it." -ForegroundColor Green
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
