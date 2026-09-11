import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/bist/models/sector_strength.dart';
import '../../stock_detail/screens/stock_detail_screen.dart';
import '../models/daily_trade_candidate.dart';
import '../services/daily_trade_scanner_service.dart';
import '../services/market_master_decision_service.dart';

class DailyTradeCommandCenter extends StatefulWidget {
  const DailyTradeCommandCenter({super.key});

  @override
  State<DailyTradeCommandCenter> createState() =>
      _DailyTradeCommandCenterState();
}

class _DailyTradeCommandCenterState extends State<DailyTradeCommandCenter> {
  late Future<List<DailyTradeCandidate>> _future;

  final Set<String> _baselineSymbols = <String>{};
  final Set<String> _alertedSymbols = <String>{};
  final List<_LiveRadarEvent> _radarEvents = <_LiveRadarEvent>[];

  Timer? _radarTimer;

  bool _refreshing = false;
  bool _radarScanning = false;
  bool _baselineReady = false;
  DateTime? _lastRadarScan;

  @override
  void initState() {
    super.initState();

    _future = _initialLoad();

    _radarTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _runLiveRadar(),
    );
  }

  @override
  void dispose() {
    _radarTimer?.cancel();
    super.dispose();
  }

  Future<List<DailyTradeCandidate>> _initialLoad() async {
    final result = await DailyTradeScannerService.instance.scan();

    final firstFive = result.take(5);

    _baselineSymbols
      ..clear()
      ..addAll(firstFive.map((e) => e.symbol));

    _baselineReady = true;

    return result;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _future = DailyTradeScannerService.instance.scan(forceRefresh: true);
    });

    try {
      final result = await _future;

      if (!_baselineReady) {
        _baselineSymbols
          ..clear()
          ..addAll(result.take(5).map((e) => e.symbol));

        _baselineReady = true;
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _runLiveRadar() async {
    if (!_baselineReady || _radarScanning) return;

    setState(() {
      _radarScanning = true;
    });

    try {
      final result = await DailyTradeScannerService.instance.scan(
        forceRefresh: true,
      );

      final now = DateTime.now();

      final fresh = result
          .where((candidate) {
            if (_baselineSymbols.contains(candidate.symbol)) {
              return false;
            }

            if (_alertedSymbols.contains(candidate.symbol)) {
              return false;
            }

            if (candidate.crocScore < 80) {
              return false;
            }

            return true;
          })
          .take(3)
          .toList();

      if (fresh.isNotEmpty) {
        for (final candidate in fresh.reversed) {
          _alertedSymbols.add(candidate.symbol);

          _radarEvents.insert(
            0,
            _LiveRadarEvent(candidate: candidate, detectedAt: now),
          );
        }

        if (_radarEvents.length > 5) {
          _radarEvents.removeRange(5, _radarEvents.length);
        }
      }

      _lastRadarScan = now;
    } finally {
      if (mounted) {
        setState(() {
          _radarScanning = false;
        });
      }
    }
  }

  String _time(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyTradeCandidate>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final candidates = snapshot.data ?? const <DailyTradeCandidate>[];
        final topThree = candidates.take(3).toList();
        final sectors = DailyTradeScannerService.instance.latestSectorStrengths;
        final globalScore = DailyTradeScannerService.instance.latestGlobalScore;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF04100C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1A4D39)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBanner(
                loading: loading,
                refreshing: _refreshing,
                candidates: candidates,
                sectors: sectors,
                globalScore: globalScore,
                onRefresh: _refresh,
              ),
              const SizedBox(height: 10),
              _CandidatesPanel(
                loading: loading,
                candidates: topThree,
                sectors: sectors,
              ),
              const SizedBox(height: 8),
              _IntradayRadarPanel(
                events: _radarEvents,
                scanning: _radarScanning,
                lastScan: _lastRadarScan,
                timeText: _lastRadarScan == null
                    ? null
                    : _time(_lastRadarScan!),
                onScanNow: _runLiveRadar,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBanner extends StatelessWidget {
  final bool loading;
  final bool refreshing;
  final List<DailyTradeCandidate> candidates;
  final List<SectorStrength> sectors;
  final int globalScore;
  final VoidCallback onRefresh;

  const _TopBanner({
    required this.loading,
    required this.refreshing,
    required this.candidates,
    required this.sectors,
    required this.globalScore,
    required this.onRefresh,
  });

  MarketMasterDecision get _master {
    return const MarketMasterDecisionService().evaluate(
      candidates: candidates,
      sectors: sectors,
      globalScore: globalScore,
    );
  }

  String get _mode {
    if (loading) return 'BIST 100 TARANIYOR';
    return _master.mode;
  }

  String get _comment {
    if (loading) {
      return 'CROC, BIST 100 hisselerini gerçek mum verisiyle tarıyor.';
    }
    return _master.comment;
  }

  Color get _tone {
    final text = _mode.toUpperCase();
    if (text.contains('ALIM') || text.contains('POZİTİF')) {
      return const Color(0xFF70F4AD);
    }
    if (text.contains('RİSK') || text.contains('SAVUNMA')) {
      return const Color(0xFFFF8A92);
    }
    return const Color(0xFFFFC857);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2C1E), Color(0xFF061711)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2D8A5D)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF123D2A),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: _tone, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CROC BUGÜN NE DİYOR?',
                  style: TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _mode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFA2B4AC),
                    fontSize: 9.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'BIST 100 yeniden tara',
            visualDensity: VisualDensity.compact,
            onPressed: refreshing ? null : onRefresh,
            icon: refreshing
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF70F4AD),
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF70F4AD),
                    size: 21,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CandidatesPanel extends StatelessWidget {
  final bool loading;
  final List<DailyTradeCandidate> candidates;
  final List<SectorStrength> sectors;

  const _CandidatesPanel({
    required this.loading,
    required this.candidates,
    required this.sectors,
  });

  String _sectorLabel(String sector) {
    final index = sectors.indexWhere((item) => item.sector == sector);
    if (index < 0) return sector;
    return '$sector #${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF173D30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFFC857),
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                loading ? 'ADAYLAR TARANIYOR' : 'BUGÜNÜN 3 FIRSATI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Text(
                'Detay için dokun',
                style: TextStyle(
                  color: Color(0xFF60776D),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (loading)
            const _LoadingRows()
          else if (candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  'Şu an güvenlik filtresini geçen fırsat yok.',
                  style: TextStyle(color: Color(0xFF8FA39A), fontSize: 10),
                ),
              ),
            )
          else
            ...List.generate(
              candidates.length,
              (index) => _CandidateRow(
                rank: index + 1,
                candidate: candidates[index],
                sectorLabel: _sectorLabel(candidates[index].sector),
              ),
            ),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final int rank;
  final DailyTradeCandidate candidate;
  final String sectorLabel;

  const _CandidateRow({
    required this.rank,
    required this.candidate,
    required this.sectorLabel,
  });

  Color get _changeColor => candidate.changePercent >= 0
      ? const Color(0xFF70F4AD)
      : const Color(0xFFFF6673);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.fromLTRB(10, 10, 9, 9),
        decoration: BoxDecoration(
          color: const Color(0xFF091A14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF15392C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Color(0xFF60776D),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  candidate.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${candidate.livePrice.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    color: _changeColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF70F4AD).withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFF70F4AD).withValues(alpha: .28),
                    ),
                  ),
                  child: Text(
                    'CROC ${candidate.crocScore}',
                    style: const TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF70F4AD),
                  size: 17,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${candidate.tradeReason} • $sectorLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA6B8B0),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: _TradeChip(
                    label: 'ALIM',
                    value:
                        '${candidate.entryLow.toStringAsFixed(2)}–${candidate.entryHigh.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TradeChip(
                    label: 'STOP',
                    value: candidate.stop.toStringAsFixed(2),
                    valueColor: const Color(0xFFFF8A92),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TradeChip(
                    label: 'HEDEF',
                    value: candidate.target.toStringAsFixed(2),
                    valueColor: const Color(0xFF70F4AD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StockDetailScreen(
          code: candidate.symbol,
          company: candidate.company,
          price: candidate.livePrice,
          change: candidate.changePercent,
          aiScore: candidate.crocScore,
        ),
      ),
    );
  }
}

class _TradeChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _TradeChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2119),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF183F30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF6F887D),
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? const Color(0xFFC8D5CF),
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntradayRadarPanel extends StatelessWidget {
  final List<_LiveRadarEvent> events;
  final bool scanning;
  final DateTime? lastScan;
  final String? timeText;
  final VoidCallback onScanNow;

  const _IntradayRadarPanel({
    required this.events,
    required this.scanning,
    required this.lastScan,
    required this.timeText,
    required this.onScanNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF244D3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.radar_rounded,
                size: 17,
                color: Color(0xFFFFC857),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GÜN İÇİ CANLI RADAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sabah listesinden sonra oluşan yeni trade fırsatları',
                      style: TextStyle(
                        color: Color(0xFF71877D),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Åimdi tara',
                visualDensity: VisualDensity.compact,
                onPressed: scanning ? null : onScanNow,
                icon: scanning
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFFC857),
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFFFFC857),
                        size: 17,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF091A14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF173D30)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: Color(0xFF70F4AD),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      scanning
                          ? 'BIST 100 taranıyor • BIST 30 dahil'
                          : '\u015eimdilik yeni g\u00fcn i\u00e7i trade f\u0131rsat\u0131 yok.',
                      style: const TextStyle(
                        color: Color(0xFFA2B4AC),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (lastScan != null)
                    Text(
                      timeText ?? '',
                      style: const TextStyle(
                        color: Color(0xFF60776D),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            )
          else
            ...events.take(3).map((event) => _IntradayRadarCard(event: event)),
          if (lastScan != null) ...[
            const SizedBox(height: 7),
            Text(
              'Son tarama $timeText â€¢ 5 dakikada bir BIST 100 taranır • BIST 30 dahil • BIST 30 dahil',
              style: const TextStyle(
                color: Color(0xFF52675F),
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IntradayRadarCard extends StatelessWidget {
  final _LiveRadarEvent event;

  const _IntradayRadarCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final candidate = event.candidate;
    final h = event.detectedAt.hour.toString().padLeft(2, '0');
    final m = event.detectedAt.minute.toString().padLeft(2, '0');

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StockDetailScreen(
              code: candidate.symbol,
              company: candidate.company,
              price: candidate.livePrice,
              change: candidate.changePercent,
              aiScore: candidate.crocScore,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1D16),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xFFFFC857).withValues(alpha: .30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFFFC857),
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  candidate.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '${candidate.livePrice.toStringAsFixed(2)} â‚º',
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '$h:$m',
                  style: const TextStyle(
                    color: Color(0xFF71877D),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC857).withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFFFFC857).withValues(alpha: .28),
                    ),
                  ),
                  child: Text(
                    'CROC ${candidate.crocScore}',
                    style: const TextStyle(
                      color: Color(0xFFFFC857),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              candidate.tradeReason,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA6B8B0),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: _TradeChip(
                    label: 'ALIM',
                    value:
                        '${candidate.entryLow.toStringAsFixed(2)}â€“${candidate.entryHigh.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TradeChip(
                    label: 'STOP',
                    value: candidate.stop.toStringAsFixed(2),
                    valueColor: const Color(0xFFFF8A92),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _TradeChip(
                    label: 'HEDEF',
                    value: candidate.target.toStringAsFixed(2),
                    valueColor: const Color(0xFF70F4AD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          LinearProgressIndicator(
            color: Color(0xFF70F4AD),
            backgroundColor: Color(0xFF123025),
          ),
          SizedBox(height: 9),
          Text(
            'BIST 100 taranıyor • fırsatlar hazırlanıyor...',
            style: TextStyle(color: Color(0xFF8FA39A), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _LiveRadarEvent {
  final DailyTradeCandidate candidate;
  final DateTime detectedAt;

  const _LiveRadarEvent({required this.candidate, required this.detectedAt});
}
