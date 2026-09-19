$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$files = @(
  'lib\core\kap_intelligence\fund_kap_intelligence_service.dart',
  'lib\core\funds\engines\fund_intelligence_engine.dart',
  'lib\features\funds\widgets\fund_finder_sheet.dart',
  'lib\features\desktop_dashboard\widgets\desktop_sidebar.dart'
)

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\kap_fund_v11_$stamp"

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

Write-Host 'CROC KAP + Fon Intelligence V1.1 kurulumu...' -ForegroundColor Green

$pre = Run-Analyze 'ON KONTROL - dart analyze .\lib'
if (Has-AnalyzerError $pre) {
  throw 'On kontrolde analyzer ERROR bulundu. Hicbir dosya degistirilmedi.'
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

foreach ($rel in $files) {
  $src = Join-Path $root $rel
  if (Test-Path $src) {
    $dst = Join-Path $backupDir $rel
    New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
    Copy-Item $src $dst -Force
  }
}

Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
  git fetch origin fund-intelligence-v1 | Out-Host
  if ($LASTEXITCODE -ne 0) { throw 'fund-intelligence-v1 fetch basarisiz.' }

  foreach ($rel in $files) {
    & git checkout origin/fund-intelligence-v1 -- $rel
    if ($LASTEXITCODE -ne 0) { throw "Git checkout basarisiz: $rel" }
  }

  Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
  & dart format `
    .\lib\core\kap_intelligence\fund_kap_intelligence_service.dart `
    .\lib\core\funds\engines\fund_intelligence_engine.dart `
    .\lib\features\funds\widgets\fund_finder_sheet.dart `
    .\lib\features\desktop_dashboard\widgets\desktop_sidebar.dart

  $post = Run-Analyze 'SON KONTROL - dart analyze .\lib'
  if (Has-AnalyzerError $post) {
    throw 'Son kontrolde analyzer ERROR bulundu.'
  }

  Write-Host "`nKurulum basarili." -ForegroundColor Green
  Write-Host 'Fon onerileri: TEFAS + risk + erisilebilen gercek Fon KAP verisi.' -ForegroundColor Green
  Write-Host 'Menu: Ana Sayfa / Fon Merkezi / KAP Radar.' -ForegroundColor Green
  Write-Host 'Not: KAP Radar Fon sekmesi sonraki adimda etkinlestirilecek.' -ForegroundColor Yellow
}
catch {
  Write-Host "`nHATA: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host 'Rollback basliyor...' -ForegroundColor Yellow

  foreach ($rel in $files) {
    $backup = Join-Path $backupDir $rel
    $target = Join-Path $root $rel
    if (Test-Path $backup) {
      New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
      Copy-Item $backup $target -Force
    }
  }

  Write-Host 'Mevcut dosyalar backup ile geri yuklendi.' -ForegroundColor Yellow
  Write-Host 'Yeni fund_kap_intelligence_service.dart rollback sirasinda silinmez; tek basina aktif karar yoluna bagli degildir.' -ForegroundColor DarkYellow
  throw
}
