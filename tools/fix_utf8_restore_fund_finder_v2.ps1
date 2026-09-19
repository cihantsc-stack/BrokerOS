$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$funds = Join-Path $root 'lib\features\funds\funds_screen.dart'
$stock = Join-Path $root 'lib\features\stock_detail\screens\stock_detail_screen.dart'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\utf8_restore_fund_finder_$stamp"

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

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

Write-Host 'CROC UTF-8 + Fon Bulucu onarimi basliyor...' -ForegroundColor Green

if (!(Test-Path $funds)) { throw "Bulunamadi: $funds" }
if (!(Test-Path $stock)) { throw "Bulunamadi: $stock" }

$pre = Run-Analyze 'ON KONTROL - dart analyze .\lib'
if (Has-AnalyzerError $pre) {
    throw 'On kontrolde analyzer ERROR bulundu. Hicbir dosya degistirilmedi.'
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item $funds (Join-Path $backupDir 'funds_screen.dart') -Force
Copy-Item $stock (Join-Path $backupDir 'stock_detail_screen.dart') -Force
Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
    $fundText = Read-Utf8 $funds

    if ($fundText -notmatch "fund_finder_sheet\.dart") {
        $anchorImport = "import '../../core/funds/models/fund_metrics_result.dart';"
        if (-not $fundText.Contains($anchorImport)) { throw 'Funds import anchor bulunamadi.' }
        $fundText = $fundText.Replace(
            $anchorImport,
            $anchorImport + "`r`nimport 'widgets/fund_finder_sheet.dart';"
        )
    }

    if ($fundText -notmatch '_beginnerFinderCard\(') {
        $searchAnchor = "              _searchBar(),"
        if (-not $fundText.Contains($searchAnchor)) { throw 'Funds build anchor bulunamadi.' }
        $fundText = $fundText.Replace(
            $searchAnchor,
            "              _beginnerFinderCard(),`r`n              const SizedBox(height: 18),`r`n              _searchBar(),"
        )

        $methodAnchor = "  Widget _searchBar() {"
        if (-not $fundText.Contains($methodAnchor)) { throw 'Funds method anchor bulunamadi.' }

        $method = @"
  Widget _beginnerFinderCard() {
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
          final compact = constraints.maxWidth < 720;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Fondan anlamıyorum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Vade, risk ve hedefini söyle. CROC gerçek TEFAS verileriyle sana uygun adayları daraltsın.',
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
                builder: (sheetContext) {
                  return FractionallySizedBox(
                    heightFactor: 0.92,
                    child: FundFinderSheet(
                      dataSource: _dataSource,
                      onSelected: _selectSuggestion,
                    ),
                  );
                },
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1D7A50),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                text,
                const SizedBox(height: 14),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 20),
              button,
            ],
          );
        },
      ),
    );
  }

"@
        $fundText = $fundText.Replace($methodAnchor, $method + $methodAnchor)
    }

    Write-Utf8NoBom $funds $fundText

    $stockText = Read-Utf8 $stock
    $stockText = $stockText.Replace('teknik gÃ¶stergeler', 'teknik göstergeler')
    $stockText = $stockText.Replace('CROC Ã¶nce sonucu sÃ¶yler', 'CROC önce sonucu söyler')
    $stockText = $stockText.Replace('Ana Ã§alÄ±ÅŸma alanÄ±', 'Ana çalışma alanı')
    Write-Utf8NoBom $stock $stockText

    Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
    & dart format $funds $stock

    $post = Run-Analyze 'SON KONTROL - dart analyze .\lib'
    if (Has-AnalyzerError $post) {
        throw 'Son kontrolde analyzer ERROR bulundu.'
    }

    Write-Host "`nOnarim basarili." -ForegroundColor Green
    Write-Host 'Fon Merkezi: Fondan anlamiyorum / CROC bana fon bulsun geri geldi.' -ForegroundColor Green
    Write-Host 'Hisse detay: DETAYLI ANALIZI GOR alt metnindeki Turkce karakter duzeltildi.' -ForegroundColor Green
}
catch {
    Write-Host "`nHATA: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path (Join-Path $backupDir 'funds_screen.dart')) {
        Copy-Item (Join-Path $backupDir 'funds_screen.dart') $funds -Force
    }
    if (Test-Path (Join-Path $backupDir 'stock_detail_screen.dart')) {
        Copy-Item (Join-Path $backupDir 'stock_detail_screen.dart') $stock -Force
    }
    & dart format $funds $stock | Out-Null
    Write-Host 'Backup geri yuklendi.' -ForegroundColor Yellow
    throw
}
