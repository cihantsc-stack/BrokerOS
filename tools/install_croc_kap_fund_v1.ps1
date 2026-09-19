$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $root

$finder = Join-Path $root 'lib\features\funds\widgets\fund_finder_sheet.dart'
$dashboard = Join-Path $root 'lib\features\desktop_dashboard\screens\desktop_dashboard_screen.dart'
$kapRadar = Join-Path $root 'lib\features\desktop_dashboard\screens\kap_radar_screen.dart'
$sidebar = Join-Path $root 'lib\features\desktop_dashboard\widgets\desktop_sidebar.dart'
$engine = Join-Path $root 'lib\core\funds\engines\fund_intelligence_engine.dart'
$fundKap = Join-Path $root 'lib\core\kap_intelligence\fund_kap_intelligence_service.dart'

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$backupDir = Join-Path $root ".croc_backups\kap_fund_v1_$stamp"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Analyze([string]$label) {
  Write-Host "`n=== $label ===" -ForegroundColor Cyan
  $out = (& dart analyze .\lib 2>&1 | Out-String)
  Write-Host $out
  return $out
}

function HasError([string]$text) {
  return [regex]::IsMatch($text, '(?im)^\s*error\s+[•-]')
}

function ReadUtf8([string]$path) {
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function WriteUtf8([string]$path, [string]$text) {
  [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}

function ReplaceRequired([string]$text, [string]$old, [string]$new, [string]$label) {
  if (-not $text.Contains($old)) { throw "Patch noktasi bulunamadi: $label" }
  return $text.Replace($old, $new)
}

Write-Host 'CROC KAP + Fon Intelligence V1 kurulumu...' -ForegroundColor Green

$pre = Analyze 'ON KONTROL - dart analyze .\lib'
if (HasError $pre) { throw 'On kontrolde analyzer ERROR var. Dosyalara dokunulmadi.' }

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
foreach ($p in @($finder,$dashboard,$kapRadar,$sidebar,$engine)) {
  if (Test-Path $p) { Copy-Item $p (Join-Path $backupDir ([IO.Path]::GetFileName($p))) -Force }
}
Write-Host "Backup: $backupDir" -ForegroundColor DarkGray

try {
  git fetch origin fund-intelligence-v1 | Out-Host
  if ($LASTEXITCODE -ne 0) { throw 'Git fetch basarisiz.' }

  git checkout origin/fund-intelligence-v1 -- `
    .\lib\features\desktop_dashboard\widgets\desktop_sidebar.dart `
    .\lib\core\funds\engines\fund_intelligence_engine.dart `
    .\lib\core\kap_intelligence\fund_kap_intelligence_service.dart
  if ($LASTEXITCODE -ne 0) { throw 'Yeni cekirdek dosyalar alinamadi.' }

  # -------------------------------------------------------------
  # FUND FINDER -> GERCEK FON KAP KATMANI
  # -------------------------------------------------------------
  $t = ReadUtf8 $finder
  if (-not $t.Contains("fund_kap_intelligence_service.dart")) {
    $t = ReplaceRequired $t `
      "import '../../../core/funds/data_sources/tefas_fund_data_source.dart';" `
      "import '../../../core/funds/data_sources/tefas_fund_data_source.dart';`nimport '../../../core/kap_intelligence/fund_kap_intelligence_service.dart';" `
      'finder import'
  }

  if (-not $t.Contains('FundKapIntelligenceService _kapService')) {
    $t = ReplaceRequired $t `
      "  final FundSuitabilityEngine _suitabilityEngine = const FundSuitabilityEngine();" `
      "  final FundSuitabilityEngine _suitabilityEngine = const FundSuitabilityEngine();`n  final FundKapIntelligenceService _kapService = FundKapIntelligenceService.instance;" `
      'finder kap field'
  }

  $t = ReplaceRequired $t `
    "          final metrics = _metricsEngine.calculate(history);`n          final intelligence = _intelligenceEngine.evaluate(metrics);" `
    "          final metrics = _metricsEngine.calculate(history);`n          final kap = await _kapService.analyzeFund(fund.fundCode);`n          final intelligence = _intelligenceEngine.evaluate(metrics, kap: kap);" `
    'finder intelligence call'
  WriteUtf8 $finder $t

  # -------------------------------------------------------------
  # MOBILE MENU -> 3 ANA MODUL
  # -------------------------------------------------------------
  $t = ReadUtf8 $dashboard
  $kararBlock = @"
              _MobileDrawerItem(
                icon: Icons.psychology_alt_rounded,
                title: 'Karar Merkezi',
                selected: selectedIndex == 3,
                onTap: () => _selectMobilePage(3),
              ),
"@
  if ($t.Contains($kararBlock)) { $t = $t.Replace($kararBlock, '') }

  $kapBlock = @"
              _MobileDrawerItem(
                icon: Icons.notifications_active_rounded,
                title: 'KAP Radar',
                selected: selectedIndex == 6,
                onTap: () => _selectMobilePage(6),
              ),
"@
  $fonBlock = @"
              _MobileDrawerItem(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Fon Merkezi',
                selected: selectedIndex == 5,
                onTap: () => _selectMobilePage(5),
              ),
"@
  if ($t.Contains($kapBlock + $fonBlock)) {
    $t = $t.Replace($kapBlock + $fonBlock, $fonBlock + $kapBlock)
  }
  WriteUtf8 $dashboard $t

  # -------------------------------------------------------------
  # KAP RADAR -> HISSE / FON SEKME ALTYAPISI
  # -------------------------------------------------------------
  $t = ReadUtf8 $kapRadar

  if (-not $t.Contains("String _radarMode = 'HISSE';")) {
    $t = ReplaceRequired $t `
      "  List<Map<String, dynamic>> _feed = [];" `
      "  List<Map<String, dynamic>> _feed = [];`n  List<Map<String, dynamic>> _allFeed = [];`n  String _radarMode = 'HISSE';" `
      'kap state'
  }

  $t = ReplaceRequired $t `
    ".where(_isRealStockDisclosure)`n          .toList();" `
    ".where(_isRealKapDisclosure)`n          .toList();" `
    'kap feed filter'

  $t = ReplaceRequired $t `
    "      final visible =`n          items.take(15).toList();" `
    "      final visible = items.where(_matchesRadarMode).take(15).toList();" `
    'kap visible'

  $t = ReplaceRequired $t `
    "        _feed = visible;`n        _loadingFeed = false;" `
    "        _allFeed = items;`n        _feed = visible;`n        _loadingFeed = false;" `
    'kap all feed'

  if (-not $t.Contains('bool _isFundDisclosure(')) {
    $anchor = "  int _indexOf(Map<String, dynamic> item) {"
    $insert = @"
  bool _isFundDisclosure(Map<String, dynamic> item) {
    final code = _text(item['fundCode']);
    final id = _text(item['fundId']);
    return code.isNotEmpty || id.isNotEmpty;
  }

  bool _isRealKapDisclosure(Map<String, dynamic> item) {
    final reports = item['subReportIds'] is List
        ? item['subReportIds'] as List
        : <dynamic>[];
    final isTest = reports.any(
      (e) => e.toString().toLowerCase().contains('testnotification'),
    );
    if (isTest) return false;
    if (_isFundDisclosure(item)) return true;
    return _isRealStockDisclosure(item);
  }

  bool _matchesRadarMode(Map<String, dynamic> item) {
    return _radarMode == 'FON'
        ? _isFundDisclosure(item)
        : !_isFundDisclosure(item);
  }

  Future<void> _changeRadarMode(String mode) async {
    if (_radarMode == mode) return;
    final visible = _allFeed.where((item) {
      return mode == 'FON' ? _isFundDisclosure(item) : !_isFundDisclosure(item);
    }).take(15).toList();

    setState(() {
      _radarMode = mode;
      _feed = visible;
      _selectedFeedItem = null;
      _selectedDetail = null;
      _selectedProfile = null;
    });

    if (visible.isNotEmpty) {
      await _selectDisclosure(visible.first);
    }
  }

"@
    $t = ReplaceRequired $t $anchor ($insert + $anchor) 'kap mode helpers'
  }

  $t = $t.Replace(
    "      if (companyId.isNotEmpty) {",
    "      if (companyId.isNotEmpty && !_isFundDisclosure(item)) {"
  )

  if (-not $t.Contains('Widget _modeSelector()')) {
    $t = ReplaceRequired $t `
      "          _header(),`n          const SizedBox(height: 16),`n          Expanded(" `
      "          _header(),`n          const SizedBox(height: 12),`n          _modeSelector(),`n          const SizedBox(height: 12),`n          Expanded(" `
      'kap build selector'

    $modeWidget = @"
  Widget _modeSelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'HISSE',
            label: Text('Hisse KAP'),
            icon: Icon(Icons.show_chart_rounded),
          ),
          ButtonSegment<String>(
            value: 'FON',
            label: Text('Fon KAP'),
            icon: Icon(Icons.account_balance_wallet_rounded),
          ),
        ],
        selected: <String>{_radarMode},
        onSelectionChanged: (values) => _changeRadarMode(values.first),
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? const Color(0xFF04140D)
                : const Color(0xFFD6E1DC);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? const Color(0xFF70F4AD)
                : const Color(0xFF0A2118);
          }),
        ),
      ),
    );
  }

"@
    $t = ReplaceRequired $t "  Widget _body() {" ($modeWidget + "  Widget _body() {") 'kap mode widget'
  }

  $t = $t.Replace(
    "                const Text(`n                  'SON KAP AKIŞI',",
    "                Text(`n                  _radarMode == 'FON' ? 'SON FON KAP AKIŞI' : 'SON HİSSE KAP AKIŞI',"
  )

  WriteUtf8 $kapRadar $t

  Write-Host "`n=== FORMAT ===" -ForegroundColor Cyan
  & dart format `
    .\lib\features\funds\widgets\fund_finder_sheet.dart `
    .\lib\features\desktop_dashboard\screens\desktop_dashboard_screen.dart `
    .\lib\features\desktop_dashboard\widgets\desktop_sidebar.dart `
    .\lib\features\desktop_dashboard\screens\kap_radar_screen.dart `
    .\lib\core\funds\engines\fund_intelligence_engine.dart `
    .\lib\core\kap_intelligence\fund_kap_intelligence_service.dart | Out-Host

  $post = Analyze 'SON KONTROL - dart analyze .\lib'
  if (HasError $post) { throw 'Son kontrolde analyzer ERROR bulundu.' }

  Write-Host "`nKURULUM BASARILI" -ForegroundColor Green
  Write-Host 'Menu: Ana Sayfa / Fon Merkezi / KAP Radar' -ForegroundColor Green
  Write-Host 'KAP Radar: Hisse KAP + Fon KAP sekmeleri' -ForegroundColor Green
  Write-Host 'Fon Intelligence: gercek fon KAP verisi bulunursa karara dahil edilir.' -ForegroundColor Green
}
catch {
  Write-Host "`nHATA: $($_.Exception.Message)" -ForegroundColor Red
  foreach ($name in @('fund_finder_sheet.dart','desktop_dashboard_screen.dart','kap_radar_screen.dart','desktop_sidebar.dart','fund_intelligence_engine.dart')) {
    $src = Join-Path $backupDir $name
    if (Test-Path $src) {
      switch ($name) {
        'fund_finder_sheet.dart' { Copy-Item $src $finder -Force }
        'desktop_dashboard_screen.dart' { Copy-Item $src $dashboard -Force }
        'kap_radar_screen.dart' { Copy-Item $src $kapRadar -Force }
        'desktop_sidebar.dart' { Copy-Item $src $sidebar -Force }
        'fund_intelligence_engine.dart' { Copy-Item $src $engine -Force }
      }
    }
  }
  if (Test-Path $fundKap) { Remove-Item $fundKap -Force }
  Write-Host 'Rollback tamamlandi.' -ForegroundColor Yellow
  throw
}
