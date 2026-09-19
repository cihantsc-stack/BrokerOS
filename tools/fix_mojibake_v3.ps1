$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backup = Join-Path $root ".croc_backups\mojibake_v3_$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$targets = @(
  'lib\features\funds\funds_screen.dart',
  'lib\features\funds\widgets\fund_finder_sheet.dart',
  'lib\features\stock_detail\screens\stock_detail_screen.dart'
)

$existing = @()
foreach ($relative in $targets) {
  $path = Join-Path $root $relative
  if (Test-Path $path) {
    $existing += $relative
    $dest = Join-Path $backup $relative
    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    Copy-Item $path $dest -Force
  }
}

Write-Host "Backup: $backup" -ForegroundColor Cyan
Write-Host "`n=== MOJIBAKE TARAMA / ONARIM ===" -ForegroundColor Cyan

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$cp1252 = [System.Text.Encoding]::GetEncoding(1252)

function Repair-Line([string]$line) {
  if ($line -notmatch '[ÃÄÅÂ]') { return $line }

  try {
    $bytes = $cp1252.GetBytes($line)
    $candidate = [System.Text.Encoding]::UTF8.GetString($bytes)

    # Dönüşüm gerçekten mojibake işaretlerini azaltıyorsa kabul et.
    $before = ([regex]::Matches($line, '[ÃÄÅÂ]')).Count
    $after = ([regex]::Matches($candidate, '[ÃÄÅÂ]')).Count
    if ($after -lt $before -and $candidate -notmatch '�') {
      return $candidate
    }
  } catch {}

  return $line
}

$changedFiles = @()
foreach ($relative in $existing) {
  $path = Join-Path $root $relative
  $lines = [System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8)
  $changed = $false

  for ($i = 0; $i -lt $lines.Length; $i++) {
    $fixed = Repair-Line $lines[$i]
    if ($fixed -ne $lines[$i]) {
      $lines[$i] = $fixed
      $changed = $true
    }
  }

  if ($changed) {
    [System.IO.File]::WriteAllLines($path, $lines, $utf8NoBom)
    $changedFiles += $relative
    Write-Host "Duzeltildi: $relative" -ForegroundColor Green
  } else {
    Write-Host "Temiz: $relative" -ForegroundColor DarkGray
  }
}

if ($changedFiles.Count -eq 0) {
  Write-Host "Mojibake kalibi bulunamadi." -ForegroundColor Yellow
}

Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
foreach ($relative in $existing) {
  dart format (Join-Path $root $relative)
}

Write-Host "`n=== ANALYZE ===" -ForegroundColor Cyan
$analyze = & dart analyze .\lib 2>&1
$analyze | ForEach-Object { Write-Host $_ }

$hasError = $false
foreach ($line in $analyze) {
  if ($line -match '^\s*error\s+-' -or $line -match '\berror -') {
    $hasError = $true
    break
  }
}

if ($hasError) {
  Write-Host "`nERROR bulundu. Rollback yapiliyor..." -ForegroundColor Red
  foreach ($relative in $existing) {
    $src = Join-Path $backup $relative
    $dst = Join-Path $root $relative
    if (Test-Path $src) { Copy-Item $src $dst -Force }
  }
  throw 'Mojibake onarimi geri alindi.'
}

Write-Host "`nUTF-8 onarimi basarili. Analyzer error yok." -ForegroundColor Green
Write-Host "Backup: $backup" -ForegroundColor Cyan
