$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$screen = Join-Path $root 'lib\features\funds\funds_screen.dart'
$helper = Join-Path $root 'lib\features\funds\widgets\fund_finder_sheet.dart'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\fund_beginner_v3_$stamp"

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

Write-Host "CROC Fon Merkezi V3 kurulumu basliyor..." -ForegroundColor Green

if (!(Test-Path $screen)) { throw "Bulunamadi: $screen" }
if (!(Test-Path $helper)) { throw "Bulunamadi: $helper - once git pull yap." }

$pre = Run-Analyze 'ON KONTROL - dart analyze .\lib'
if (Has-AnalyzerError $pre) {
    throw 'On kontrolde analyzer ERROR bulundu. Hicbir dosya degistirilmedi.'
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item $screen (Join-Path $backupDir 'funds_screen.dart') -Force
Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
    $text = Get-Content $screen -Raw -Encoding UTF8

    if ($text -notmatch "widgets/fund_finder_sheet\.dart") {
        $anchor = "import '../../core/funds/models/fund_metrics_result.dart';"
        if (!$text.Contains($anchor)) { throw 'Import anchor bulunamadi.' }
        $text = $text.Replace($anchor, "$anchor`r`nimport 'widgets/fund_finder_sheet.dart';")
    }

    if ($text -notmatch '_beginnerEntryCard\(\)') {
        $anchor = @"
              const SizedBox(height: 18),
              _searchBar(),
"@
        $replacement = @"
              const SizedBox(height: 18),
              _beginnerEntryCard(),
              const SizedBox(height: 14),
              _searchBar(),
"@
        if (!$text.Contains($anchor)) { throw 'Beginner entry anchor bulunamadi.' }
        $text = $text.Replace($anchor, $replacement)
    }

    $oldMain = @"
                _beginnerSummary(metrics),
                const SizedBox(height: 14),
                _performanceGrid(metrics),
                const SizedBox(height: 14),
                _riskPanel(metrics),
                const SizedBox(height: 14),
                _detailExpansion(history, metrics),
"@
    $newMain = @"
                _beginnerSummary(metrics),
                const SizedBox(height: 14),
                _detailExpansion(history, metrics),
"@
    if ($text.Contains($oldMain)) {
        $text = $text.Replace($oldMain, $newMain)
    }

    $oldDetails = @"
            children: [
              _professionalDetail(history, metrics),
              const SizedBox(height: 12),
              _waitingPanel(),
            ],
"@
    $newDetails = @"
            children: [
              _performanceGrid(metrics),
              const SizedBox(height: 12),
              _riskPanel(metrics),
              const SizedBox(height: 12),
              _professionalDetail(history, metrics),
              const SizedBox(height: 12),
              _waitingPanel(),
            ],
"@
    if ($text.Contains($oldDetails)) {
        $text = $text.Replace($oldDetails, $newDetails)
    }

    if ($text -notmatch 'Widget _beginnerEntryCard\(') {
        $methodAnchor = '  Widget _searchBar() {'
        if (!$text.Contains($methodAnchor)) { throw 'Method anchor bulunamadi.' }
        $method = @"
  Widget _beginnerEntryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;
          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Fondan anlamıyorum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Vade, risk ve hedefini söyle. CROC gerçek TEFAS fonları içinden uygun fon türünü daraltsın.',
                style: TextStyle(
                  color: Color(0xFF91A69D),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          );

          final button = FilledButton.icon(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => FractionallySizedBox(
                  heightFactor: .88,
                  child: FundFinderSheet(
                    dataSource: _dataSource,
                    onSelected: _selectSuggestion,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D7A50),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text(
              'CROC bana fon bulsun',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textBlock,
                const SizedBox(height: 14),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: textBlock),
              const SizedBox(width: 18),
              button,
            ],
          );
        },
      ),
    );
  }

"@
        $text = $text.Replace($methodAnchor, $method + $methodAnchor)
    }

    Set-Content $screen $text -Encoding UTF8

    Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
    & dart format $screen $helper

    $post = Run-Analyze 'SON KONTROL - dart analyze .\lib'
    if (Has-AnalyzerError $post) {
        throw 'Son kontrolde analyzer ERROR bulundu.'
    }

    Write-Host "`nCROC Fon Merkezi V3 basariyla kuruldu." -ForegroundColor Green
    Write-Host 'Yeni: CROC bana fon bulsun + sade ana ekran + detaylar DETAYLI ANALIZI GOR altinda.' -ForegroundColor Green
}
catch {
    Write-Host "`nHATA: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path (Join-Path $backupDir 'funds_screen.dart')) {
        Copy-Item (Join-Path $backupDir 'funds_screen.dart') $screen -Force
        & dart format $screen | Out-Null
        Write-Host 'funds_screen.dart backup geri yuklendi.' -ForegroundColor Yellow
    }
    throw
}
