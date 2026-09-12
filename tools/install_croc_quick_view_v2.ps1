$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

Write-Host "=== 1/5 PRE ANALYZE ===" -ForegroundColor Cyan
$pre = & dart analyze .\lib 2>&1
$pre | ForEach-Object { Write-Host $_ }

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backup = Join-Path $root ".croc_backups\CROC_QUICK_VIEW_V2_$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$target = 'lib\core\trade\croc_horizon_engine.dart'
$targetPath = Join-Path $root $target
$backupPath = Join-Path $backup $target
New-Item -ItemType Directory -Path (Split-Path $backupPath -Parent) -Force | Out-Null
Copy-Item $targetPath $backupPath -Force
Write-Host "`n=== 2/5 BACKUP ===" -ForegroundColor Cyan
Write-Host "Backup: $backup"

Write-Host "`n=== 3/5 GITHUB V2 ===" -ForegroundColor Cyan
git fetch origin fund-intelligence-v1 | Out-Host
git checkout origin/fund-intelligence-v1 -- .\lib\core\trade\croc_horizon_engine.dart

Write-Host "`n=== 4/5 FORMAT ===" -ForegroundColor Cyan
dart format .\lib\core\trade\croc_horizon_engine.dart | Out-Host

Write-Host "`n=== 5/5 POST ANALYZE ===" -ForegroundColor Cyan
$post = & dart analyze .\lib 2>&1
$post | ForEach-Object { Write-Host $_ }

$hasError = $false
foreach ($line in $post) {
  if ($line -match '^\s*error\s+-' -or $line -match '\berror -') {
    $hasError = $true
    break
  }
}

if ($hasError) {
  Copy-Item $backupPath $targetPath -Force
  throw 'Analyzer error bulundu. V2 geri alindi.'
}

Write-Host "`nCROC HIZLI GORUS V2 kuruldu. Analyzer error yok." -ForegroundColor Green
Write-Host "Gun ici giris daraltildi; hacim zayifsa AL yerine teyit/kademeli karar verilir."
Write-Host "3-6 ayda eksik KAP/fon/temel/makro pozitif puan sayilmaz."
Write-Host "Backup: $backup"
