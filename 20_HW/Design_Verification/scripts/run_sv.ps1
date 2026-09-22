param(
    [Parameter(Mandatory = $true)]
    [string]$SourceFile
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$buildDirectory = Join-Path $projectRoot "build"

if (-not (Get-Command iverilog -ErrorAction SilentlyContinue)) {
    throw "iverilog을 찾을 수 없습니다. MSYS2의 Icarus Verilog가 PATH에 포함되어 있는지 확인하세요."
}

if (-not (Test-Path -LiteralPath $SourceFile)) {
    throw "소스 파일을 찾을 수 없습니다: $SourceFile"
}

New-Item -ItemType Directory -Force -Path $buildDirectory | Out-Null
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile)
$outputFile = Join-Path $buildDirectory "$baseName.vvp"

& iverilog -g2012 -Wall -o $outputFile $SourceFile
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& vvp $outputFile
exit $LASTEXITCODE
