$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$finder = Join-Path $root 'lib\features\funds\widgets\fund_finder_sheet.dart'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\fund_intelligence_v1_$stamp"

function Run-Analyze {
    param([string]$Label)
    Write-Host "`n=== $Label ===" -ForegroundColor Cyan
    $output = (& dart analyze .\lib 2>&1 | Out-String)
    Write-Host $output
    return $output
}

function Has-AnalyzerError {
    param([string]$Text)
    return [regex]::IsMatch($Text, '(?im)^\s*error\s+[•-]')
}

Write-Host 'CROC Fon Intelligence V1 kurulumu basliyor...' -ForegroundColor Green

if (!(Test-Path $finder)) { throw "Bulunamadi: $finder" }

$pre = Run-Analyze 'ON KONTROL - dart analyze .\lib'
if (Has-AnalyzerError $pre) {
    throw 'On kontrolde analyzer ERROR bulundu. Hicbir dosya degistirilmedi.'
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item $finder (Join-Path $backupDir 'fund_finder_sheet.dart') -Force
Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
    git fetch origin fund-intelligence-v1 | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'fund-intelligence-v1 fetch basarisiz.' }

    $newFinder = git show origin/fund-intelligence-v1:lib/features/funds/widgets/fund_finder_sheet.dart
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($newFinder | Out-String))) {
        throw 'Yeni fund_finder_sheet.dart okunamadi.'
    }

    Set-Content -Path $finder -Value ($newFinder | Out-String) -Encoding UTF8

    Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
    & dart format `
      .\lib\features\funds\widgets\fund_finder_sheet.dart `
      .\lib\core\funds\engines\fund_intelligence_engine.dart `
      .\lib\core\funds\engines\fund_suitability_engine.dart `
      .\lib\core\funds\models\fund_intelligence_result.dart `
      .\lib\core\funds\models\fund_candidate_result.dart

    $post = Run-Analyze 'SON KONTROL - dart analyze .\lib'
    if (Has-AnalyzerError $post) {
        throw 'Son kontrolde analyzer ERROR bulundu.'
    }

    Write-Host "`nCROC Fon Intelligence V1 basariyla kuruldu." -ForegroundColor Green
    Write-Host 'Yeni: Gercek TEFAS gecmisi + risk + profil uyumu ile aday siralama.' -ForegroundColor Green
    Write-Host 'Ilk 3 aday sade, digerleri acilir listede.' -ForegroundColor Green
}
catch {
    Write-Host "`nHATA: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path (Join-Path $backupDir 'fund_finder_sheet.dart')) {
        Copy-Item (Join-Path $backupDir 'fund_finder_sheet.dart') $finder -Force
        & dart format $finder | Out-Null
        Write-Host 'fund_finder_sheet.dart backup geri yuklendi.' -ForegroundColor Yellow
    }
    throw
}
