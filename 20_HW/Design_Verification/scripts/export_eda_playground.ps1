param(
    [Parameter(Mandatory = $true)]
    [string]$CurrentFile,

    [ValidateSet("none", "design", "testbench")]
    [string]$Copy = "none"
)

$ErrorActionPreference = "Stop"
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$resolvedFile = (Resolve-Path -LiteralPath $CurrentFile).Path

if (-not $resolvedFile.StartsWith($workspaceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "현재 파일이 Design_Verification 작업공간 밖에 있습니다: $resolvedFile"
}

$relativePath = $resolvedFile.Substring($workspaceRoot.Length).TrimStart('\', '/')
$projectName = $relativePath.Split([char[]]@('\', '/'))[0]
$projectRoot = Join-Path $workspaceRoot $projectName
$rtlDirectory = Join-Path $projectRoot "rtl"
$tbDirectory = Join-Path $projectRoot "tb"

if (-not (Test-Path -LiteralPath $rtlDirectory) -or -not (Test-Path -LiteralPath $tbDirectory)) {
    throw "현재 파일에서 RTL/TB 프로젝트를 찾지 못했습니다. 프로젝트의 rtl 또는 tb 파일을 연 뒤 다시 실행하세요."
}

$exportDirectory = Join-Path $projectRoot "eda_export"
$designOutput = Join-Path $exportDirectory "design.sv"
$testbenchOutput = Join-Path $exportDirectory "testbench.sv"
New-Item -ItemType Directory -Force -Path $exportDirectory | Out-Null

function Get-OrderedSourceFiles {
    param(
        [string]$Directory,
        [string]$OrderFile
    )

    if (Test-Path -LiteralPath $OrderFile) {
        $orderedFiles = foreach ($line in Get-Content -LiteralPath $OrderFile) {
            $entry = $line.Trim()
            if (-not $entry -or $entry.StartsWith("#")) { continue }
            $sourcePath = Join-Path $projectRoot $entry
            if (-not (Test-Path -LiteralPath $sourcePath)) {
                throw "순서 파일에 지정된 소스를 찾을 수 없습니다: $entry"
            }
            Get-Item -LiteralPath $sourcePath
        }
        return @($orderedFiles)
    }

    return @(Get-ChildItem -LiteralPath $Directory -File -Recurse -Filter "*.sv" | Sort-Object FullName)
}

function Write-Bundle {
    param(
        [System.IO.FileInfo[]]$Files,
        [string]$OutputPath,
        [string]$BundleName
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("// Generated for EDA Playground: $projectName / $BundleName")
    $lines.Add("// 원본은 rtl/ 및 tb/에서 수정하고 이 파일은 직접 수정하지 마세요.")
    $lines.Add("")

    if ($Files.Count -eq 0) {
        $lines.Add("// 아직 $BundleName 소스가 없습니다.")
    } else {
        foreach ($file in $Files) {
            $relativeSource = $file.FullName.Substring($projectRoot.Length).TrimStart('\', '/')
            $lines.Add("// ===== BEGIN: $relativeSource =====")
            $lines.Add((Get-Content -Raw -LiteralPath $file.FullName).TrimEnd())
            $lines.Add("// ===== END: $relativeSource =====")
            $lines.Add("")
        }
    }

    Set-Content -LiteralPath $OutputPath -Value $lines -Encoding utf8
}

$designFiles = Get-OrderedSourceFiles -Directory $rtlDirectory -OrderFile (Join-Path $projectRoot "eda_design_order.txt")
$testbenchFiles = Get-OrderedSourceFiles -Directory $tbDirectory -OrderFile (Join-Path $projectRoot "eda_testbench_order.txt")

Write-Bundle -Files $designFiles -OutputPath $designOutput -BundleName "design"
Write-Bundle -Files $testbenchFiles -OutputPath $testbenchOutput -BundleName "testbench"

Write-Host "EDA Playground 파일 생성 완료:"
Write-Host "  Design   : $designOutput"
Write-Host "  Testbench: $testbenchOutput"

if ($Copy -eq "design") {
    Get-Content -Raw -LiteralPath $designOutput | Set-Clipboard
    Write-Host "design.sv 내용을 클립보드에 복사했습니다."
} elseif ($Copy -eq "testbench") {
    Get-Content -Raw -LiteralPath $testbenchOutput | Set-Clipboard
    Write-Host "testbench.sv 내용을 클립보드에 복사했습니다."
}
