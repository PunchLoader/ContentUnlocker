param(
    [string]$GameDir = 'F:\Codex\MBP_PROJ\ModdedGame',
    [string]$PunchLoaderRoot = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'build.ps1') -PunchLoaderRoot $PunchLoaderRoot
$target = Join-Path $GameDir 'Mods\ContentUnlocker'
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'build\ContentUnlocker.dll') `
    -Destination (Join-Path $target 'ContentUnlocker.dll') -Force
Copy-Item -LiteralPath (Join-Path $root 'mod\plugin.json') `
    -Destination (Join-Path $target 'plugin.json') -Force
Write-Host "Deployed ContentUnlocker to: $target"

