param(
    [string]$PunchLoaderRoot = '',
    [string]$Csc = 'C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'build.ps1') -PunchLoaderRoot $PunchLoaderRoot -Csc $Csc
$manifest = Get-Content -LiteralPath (Join-Path $root 'mod\plugin.json') -Raw |
    ConvertFrom-Json
if ($manifest.id -ne 'ContentUnlocker' -or [string]::IsNullOrEmpty($manifest.version)) {
    throw 'Invalid ContentUnlocker plugin.json'
}
$name = 'ContentUnlocker-v' + $manifest.version
$dist = Join-Path $root 'dist'
$stage = Join-Path (Join-Path $dist 'unpacked') $name
$modStage = Join-Path $stage 'ContentUnlocker'
$zip = Join-Path $dist ($name + '.zip')
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$resolvedDist = [IO.Path]::GetFullPath($dist).TrimEnd('\') + '\'
foreach ($candidate in @($stage, $zip)) {
    $resolved = [IO.Path]::GetFullPath($candidate)
    if (-not $resolved.StartsWith($resolvedDist,
        [StringComparison]::OrdinalIgnoreCase)) {
        throw "Release path escaped dist: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
New-Item -ItemType Directory -Force -Path $modStage | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'build\ContentUnlocker.dll') `
    -Destination (Join-Path $modStage 'ContentUnlocker.dll') -Force
Copy-Item -LiteralPath (Join-Path $root 'mod\plugin.json') `
    -Destination (Join-Path $modStage 'plugin.json') -Force
Copy-Item -LiteralPath (Join-Path $root 'README.md') `
    -Destination (Join-Path $modStage 'README.md') -Force
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($zip)
try {
    $entries = @($archive.Entries | ForEach-Object { $_.FullName -replace '\\', '/' })
    foreach ($required in @(
        'ContentUnlocker/ContentUnlocker.dll',
        'ContentUnlocker/plugin.json',
        'ContentUnlocker/README.md'
    )) {
        if ($entries -notcontains $required) {
            throw "Package entry missing: $required"
        }
    }
    if (@($entries | Where-Object { -not $_.StartsWith('ContentUnlocker/') }).Count -ne 0) {
        throw 'Package contains entries outside ContentUnlocker/'
    }
}
finally {
    $archive.Dispose()
}
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash
Write-Host "Package: $zip"
Write-Host "SHA256: $hash"
