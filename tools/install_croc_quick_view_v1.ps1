$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$target = Join-Path $root 'lib\features\stock_detail\screens\stock_detail_screen.dart'
$engine = Join-Path $root 'lib\core\trade\croc_horizon_engine.dart'
$widget = Join-Path $root 'lib\features\stock_detail\widgets\croc_quick_view_card.dart'

if (!(Test-Path $target)) { throw "Bulunamadi: $target" }
if (!(Test-Path $engine)) { throw "Bulunamadi: $engine" }
if (!(Test-Path $widget)) { throw "Bulunamadi: $widget" }

Write-Host "=== 1/6 ON ANALYZE ===" -ForegroundColor Cyan
$pre = & dart analyze .\lib 2>&1
$pre | ForEach-Object { Write-Host $_ }
$preHasError = $false
foreach ($line in $pre) {
  if ($line -match '^\s*error\s+-' -or $line -match '\berror -') {
    $preHasError = $true
    break
  }
}
if ($preHasError) { throw 'Aktif lib zaten analyzer error iceriyor. Kurulum durduruldu.' }

Write-Host "`n=== 2/6 BACKUP ===" -ForegroundColor Cyan
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupRoot = Join-Path $root ".croc_backups\CROC_QUICK_VIEW_V1_$stamp"
$backupFile = Join-Path $backupRoot 'lib\features\stock_detail\screens\stock_detail_screen.dart'
New-Item -ItemType Directory -Path (Split-Path $backupFile -Parent) -Force | Out-Null
Copy-Item $target $backupFile -Force
Write-Host "Backup: $backupRoot" -ForegroundColor Green

Write-Host "`n=== 3/6 PATCH ===" -ForegroundColor Cyan
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$text = [System.IO.File]::ReadAllText($target, [System.Text.Encoding]::UTF8)

$importLine = "import '../widgets/croc_quick_view_card.dart';"
if ($text -notmatch [regex]::Escape($importLine)) {
  $anchorImport = "import '../widgets/croc_scale_in_plan_card.dart';"
  if ($text -notmatch [regex]::Escape($anchorImport)) {
    throw 'Import anchor bulunamadi.'
  }
  $text = $text.Replace($anchorImport, "$anchorImport`r`n$importLine")
}

$cardCall = @"
                        CrocQuickViewCard(
                          price: _displayPrice,
                          technical: _analysis,
                          master: _masterResult,
                          kap: _kapResult,
                        ),
"@

if ($text -notmatch 'CrocQuickViewCard\(') {
  $anchorCard = "                        _buildCrocDecisionHero(mobile),"
  if ($text -notmatch [regex]::Escape($anchorCard)) {
    throw 'Decision hero anchor bulunamadi.'
  }
  $text = $text.Replace($anchorCard, "$anchorCard`r`n$cardCall")
}

# Kalan tek bozuk alt basligi da ayni anda temizle.
$text = $text.Replace(
  'RSI • MACD • teknik gÃ¶stergeler • KAP • finansallar',
  'RSI • MACD • teknik göstergeler • KAP • finansallar'
)

[System.IO.File]::WriteAllText($target, $text, $utf8NoBom)
Write-Host 'StockDetailScreen patchlendi.' -ForegroundColor Green

Write-Host "`n=== 4/6 FORMAT ===" -ForegroundColor Cyan
dart format $engine
dart format $widget
dart format $target

Write-Host "`n=== 5/6 POST ANALYZE ===" -ForegroundColor Cyan
$post = & dart analyze .\lib 2>&1
$post | ForEach-Object { Write-Host $_ }
$postHasError = $false
foreach ($line in $post) {
  if ($line -match '^\s*error\s+-' -or $line -match '\berror -') {
    $postHasError = $true
    break
  }
}

if ($postHasError) {
  Write-Host "`nAnalyzer ERROR bulundu. Rollback yapiliyor..." -ForegroundColor Red
  Copy-Item $backupFile $target -Force
  dart format $target | Out-Null
  throw 'CROC Quick View kurulumu geri alindi.'
}

Write-Host "`n=== 6/6 TAMAM ===" -ForegroundColor Cyan
Write-Host 'CROC HIZLI GORUS V1 kuruldu. Analyzer error yok.' -ForegroundColor Green
Write-Host 'Vadeler: Gun Ici / 1 Hafta / 1 Ay / 3 Ay / 6 Ay' -ForegroundColor Green
Write-Host 'Uzun vadede eksik fon-temel-makro katmanlari olumlu varsayilmaz.' -ForegroundColor Yellow
Write-Host "Backup: $backupRoot" -ForegroundColor Cyan
