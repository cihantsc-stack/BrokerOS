$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$screen = Join-Path $root 'lib\features\funds\funds_screen.dart'
$helper = Join-Path $root 'lib\features\funds\widgets\fund_finder_sheet.dart'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\fund_finder_v31_$stamp"

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

function Repair-Mojibake {
    param([string]$Text)

    $pairs = @(
        @(([char]0x00C4).ToString() + [char]0x00B1, [char]0x0131),
        @(([char]0x00C4).ToString() + [char]0x00B0, [char]0x0130),
        @(([char]0x00C4).ToString() + [char]0x009F, [char]0x011F),
        @(([char]0x00C4).ToString() + [char]0x009E, [char]0x011E),
        @(([char]0x00C5).ToString() + [char]0x009F, [char]0x015F),
        @(([char]0x00C5).ToString() + [char]0x009E, [char]0x015E),
        @(([char]0x00C3).ToString() + [char]0x00BC, [char]0x00FC),
        @(([char]0x00C3).ToString() + [char]0x009C, [char]0x00DC),
        @(([char]0x00C3).ToString() + [char]0x00B6, [char]0x00F6),
        @(([char]0x00C3).ToString() + [char]0x0096, [char]0x00D6),
        @(([char]0x00C3).ToString() + [char]0x00A7, [char]0x00E7),
        @(([char]0x00C3).ToString() + [char]0x0087, [char]0x00C7)
    )

    foreach ($pair in $pairs) {
        $Text = $Text.Replace([string]$pair[0], [string]$pair[1])
    }
    return $Text
}

if (!(Test-Path $screen)) { throw "Missing: $screen" }
if (!(Test-Path $helper)) { throw "Missing: $helper" }

$pre = Run-Analyze 'PRECHECK - dart analyze .\lib'
if (Has-AnalyzerError $pre) {
    throw 'Analyzer ERROR found before install. No files changed.'
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item $screen (Join-Path $backupDir 'funds_screen.dart') -Force
Copy-Item $helper (Join-Path $backupDir 'fund_finder_sheet.dart') -Force
Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
    $screenText = Get-Content $screen -Raw -Encoding UTF8
    $screenText = Repair-Mojibake $screenText
    Set-Content $screen $screenText -Encoding UTF8

    $helperText = Get-Content $helper -Raw -Encoding UTF8

    $startToken = '  Future<void> _findCandidates() async {'
    $endToken = "`r`n  @override`r`n  Widget build(BuildContext context) {"
    $start = $helperText.IndexOf($startToken)
    $end = $helperText.IndexOf($endToken, $start)

    if ($start -lt 0 -or $end -lt 0) {
        $endToken = "`n  @override`n  Widget build(BuildContext context) {"
        $end = $helperText.IndexOf($endToken, $start)
    }

    if ($start -lt 0 -or $end -lt 0) {
        throw 'Finder method anchor not found.'
    }

    $replacement = @'
  Future<void> _findCandidates() async {
    final query = _queryForSelection();
    setState(() {
      _loading = true;
      _summary = null;
      _results = const <FundSearchItem>[];
    });

    try {
      final results = await widget.dataSource.searchFunds(query, limit: 8);
      if (!mounted) return;

      setState(() {
        _results = results;
        _summary = results.isEmpty
            ? 'Bu secim icin gercek TEFAS katalogunda aday bulunamadi.'
            : '${_categoryLabel(query)} icinden ${results.length} gercek TEFAS adayi bulundu.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _results = const <FundSearchItem>[];
        _summary = 'Fon taramasi tamamlanamadi: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
'@

    $helperText = $helperText.Substring(0, $start) + $replacement + $helperText.Substring($end)
    Set-Content $helper $helperText -Encoding UTF8

    Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
    & dart format $screen $helper

    $post = Run-Analyze 'POSTCHECK - dart analyze .\lib'
    if (Has-AnalyzerError $post) {
        throw 'Analyzer ERROR found after install.'
    }

    Write-Host "`nCROC Fund Finder V3.1 repair installed successfully." -ForegroundColor Green
    Write-Host 'Fixed: stuck loading + visible search errors + mojibake repair.' -ForegroundColor Green
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    Copy-Item (Join-Path $backupDir 'funds_screen.dart') $screen -Force
    Copy-Item (Join-Path $backupDir 'fund_finder_sheet.dart') $helper -Force
    & dart format $screen $helper | Out-Null
    Write-Host 'Rollback completed.' -ForegroundColor Yellow
    throw
}
