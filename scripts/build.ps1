param(
    [string]$PunchLoaderRoot = '',
    [string]$Csc = 'C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrEmpty($PunchLoaderRoot)) {
    $PunchLoaderRoot = Join-Path (Split-Path -Parent $root) 'PunchLoader'
}
$PunchLoaderRoot = [IO.Path]::GetFullPath($PunchLoaderRoot)

$loader = Join-Path $PunchLoaderRoot 'build\PunchLoader.dll'
$unity = Join-Path $PunchLoaderRoot 'deps\Unity\UnityEngine.dll'
$mscorlib = Join-Path $PunchLoaderRoot 'deps\Game\Common\mscorlib.dll'
$source = Join-Path $root 'src\ContentUnlocker.cs'
$outputDirectory = Join-Path $root 'build'
$output = Join-Path $outputDirectory 'ContentUnlocker.dll'
foreach ($required in @($Csc, $loader, $unity, $mscorlib, $source)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required build input not found: $required"
    }
}
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
& $Csc /nologo /target:library "/out:$output" "/reference:$unity" `
    "/reference:$loader" "/reference:$mscorlib" /nostdlib $source
if ($LASTEXITCODE -ne 0) {
    throw "ContentUnlocker build failed: $LASTEXITCODE"
}
Write-Host "Built: $output"

