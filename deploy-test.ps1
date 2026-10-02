<#
.SYNOPSIS
    Copies the mod in .\mod into the Don't Starve Together mods folder as a
    test build ("Waypoint Mod (TEST)" with cheats enabled).

.DESCRIPTION
    1. Mirrors .\mod -> <DST>\mods\waypoint (stale files in the target are removed).
    2. Copies .\dev\scripts\* (test-only tools) into the copy's scripts folder.
    3. In the COPY only (never the repo):
         - modinfo.lua : name = "Waypoint Mod (TEST)"
         - modmain.lua : uncomments  GLOBAL.CHEATS_ENABLED = true
         - modmain.lua : uncomments  require("waypointdevtools")(env)
                         (test mode: god + creative + invisible on spawn; console: c_wphelp())
    Files are read/written as UTF-8 without BOM and line endings are preserved.

.PARAMETER Destination
    Target mod folder. Defaults to the standard Steam install path.

.EXAMPLE
    .\deploy-test.ps1
    .\deploy-test.ps1 -Destination "D:\SteamLibrary\steamapps\common\Don't Starve Together\mods\waypoint"
#>
[CmdletBinding()]
param(
    [string]$Destination = "C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together\mods\waypoint"
)

$ErrorActionPreference = 'Stop'

$Source = Join-Path $PSScriptRoot 'mod'
if (-not (Test-Path (Join-Path $Source 'modinfo.lua'))) {
    throw "Could not find '$Source\modinfo.lua'. Run this script from the repo root (the mod files must live in .\mod)."
}

$modsDir = Split-Path $Destination -Parent
if (-not (Test-Path $modsDir)) {
    throw "DST mods folder not found: '$modsDir'. Pass -Destination if DST is installed elsewhere."
}

Write-Host "Source      : $Source"
Write-Host "Destination : $Destination"

# --- 1. Mirror files -------------------------------------------------------
# /MIR  mirror (copies new/changed, deletes files no longer in source)
# /NJH /NJS /NP /NDL  quieter output
robocopy $Source $Destination /MIR /NJH /NJS /NP /NDL /R:2 /W:1 | Out-Host
$rc = $LASTEXITCODE
if ($rc -ge 8) {
    throw "robocopy failed with exit code $rc. If this is 'Access is denied', run the script as Administrator or close DST."
}
$global:LASTEXITCODE = 0

# --- 2. Test-only scripts ---------------------------------------------------
# dev\scripts is never part of mod\ (the folder that gets uploaded), so these
# only exist in the test copy. Copied after the mirror, so /MIR above removes
# them first and this puts the current version back.
$DevScripts = Join-Path $PSScriptRoot 'dev\scripts'
if (Test-Path $DevScripts) {
    Copy-Item -Path (Join-Path $DevScripts '*') -Destination (Join-Path $Destination 'scripts') -Recurse -Force
    Write-Host "Copied dev\scripts -> scripts (test-only tools)" -ForegroundColor Green
}

# --- 3. Patch the copy for testing ----------------------------------------
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Update-File {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement,
        [string]$Description
    )
    $text = [System.IO.File]::ReadAllText($Path, $utf8NoBom)
    $regex = [regex]::new($Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $regex.IsMatch($text)) {
        Write-Warning "Pattern not found in $(Split-Path $Path -Leaf) - skipped: $Description"
        return
    }
    $new = $regex.Replace($text, $Replacement, 1)
    [System.IO.File]::WriteAllText($Path, $new, $utf8NoBom)
    Write-Host "Patched $(Split-Path $Path -Leaf): $Description" -ForegroundColor Green
}

# modinfo.lua -> test name (first top-level `name = "..."` line only)
Update-File -Path (Join-Path $Destination 'modinfo.lua') `
    -Pattern '^name\s*=\s*"[^"]*"' `
    -Replacement 'name = "Waypoint Mod (TEST)"' `
    -Description 'name = "Waypoint Mod (TEST)"'

# modmain.lua -> enable cheats (console commands such as c_reset())
Update-File -Path (Join-Path $Destination 'modmain.lua') `
    -Pattern '^([ \t]*)--[ \t]*(GLOBAL\.CHEATS_ENABLED[ \t]*=[ \t]*true)' `
    -Replacement '$1$2' `
    -Description 'GLOBAL.CHEATS_ENABLED = true'

# modmain.lua -> load the test-only tools (dev\scripts\waypointdevtools.lua):
# test mode (god + creative + invisible) and c_wpscatter / c_wpring / c_wpclear
Update-File -Path (Join-Path $Destination 'modmain.lua') `
    -Pattern '^([ \t]*)--[ \t]*(require\("waypointdevtools"\)\(env\))' `
    -Replacement '$1$2' `
    -Description 'require("waypointdevtools")(env) (test mode + c_wp* commands)'

Write-Host ""
Write-Host "Done. Enable 'Waypoint Mod (TEST)' in DST > Mods (disable the Workshop copy to avoid loading both)." -ForegroundColor Cyan
Write-Host "Test mode (god, creative, invisible) turns on when you spawn. Commands: console (~) on Local (Ctrl), c_wphelp()." -ForegroundColor Cyan
