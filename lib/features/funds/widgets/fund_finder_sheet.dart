import 'package:flutter/material.dart';

import '../../../core/funds/data_sources/tefas_fund_data_source.dart';
import '../../../core/funds/engines/fund_intelligence_engine.dart';
import '../../../core/funds/engines/fund_metrics_engine.dart';
import '../../../core/funds/engines/fund_suitability_engine.dart';
import '../../../core/funds/models/fund_candidate_result.dart';
import '../../../core/kap_intelligence/fund_kap_intelligence_service.dart';

class FundFinderSheet extends StatefulWidget {
  final TefasFundDataSource dataSource;
  final ValueChanged<FundSearchItem> onSelected;

  const FundFinderSheet({
    super.key,
    required this.dataSource,
    required this.onSelected,
  });

  @override
  State<FundFinderSheet> createState() => _FundFinderSheetState();
}

class _FundFinderSheetState extends State<FundFinderSheet> {
  final FundMetricsEngine _metricsEngine = const FundMetricsEngine();
  final FundIntelligenceEngine _intelligenceEngine = const FundIntelligenceEngine();
  final FundSuitabilityEngine _suitabilityEngine = const FundSuitabilityEngine();
  final FundKapIntelligenceService _fundKapService =
      FundKapIntelligenceService.instance;

  String _horizon = '3-12 AY';
  String _risk = 'ORTA';
  String _goal = 'DENGELI BUYUME';
  bool _loading = false;
  String? _summary;
  String? _error;
  List<FundCandidateResult> _results = const <FundCandidateResult>[];

  String _queryForSelection() {
    if (_goal == 'PARAYI KORU') return 'PARA PIYASASI';
    if (_horizon == '0-3 AY' && _goal == 'BUYUME') return 'DEGISKEN';
    if (_risk == 'DUSUK') return 'BORCLANMA ARACLARI';
    if (_goal == 'BUYUME' && _horizon != '0-3 AY') return 'HISSE SENEDI';
    if (_risk == 'YUKSEK' && _horizon == '1 YIL+') return 'HISSE SENEDI';
    return 'DEGISKEN';
  }

  String _categoryLabel(String query) {
    switch (query) {
      case 'PARA PIYASASI':
        return 'Para piyasası';
      case 'BORCLANMA ARACLARI':
        return 'Borçlanma araçları';
      case 'HISSE SENEDI':
        return 'Hisse senedi';
      default:
        return 'Değişken';
    }
  }

  Future<void> _findCandidates() async {
    final query = _queryForSelection();
    setState(() {
      _loading = true;
      _summary = null;
      _error = null;
      _results = const <FundCandidateResult>[];
    });

    try {
      final catalog = await widget.dataSource.searchFunds(query, limit: 8);

      final ranked = await Future.wait(
        catalog.map((fund) async {
          final history = await widget.dataSource.fetchHistory(
            fund.fundCode,
            periodMonths: 12,
          );
          final metrics = _metricsEngine.calculate(history);
          final kap = await _fundKapService.analyzeFund(fund.fundCode);
          final intelligence = _intelligenceEngine.evaluate(
            metrics,
            kap: kap,
          );
          final score = _suitabilityEngine.score(
            metrics: metrics,
            intelligence: intelligence,
            horizon: _horizon,
            risk: _risk,
            goal: _goal,
          );

          final reasons = <String>[
            ..._suitabilityEngine.reasons(
              metrics: metrics,
              horizon: _horizon,
              risk: _risk,
              goal: _goal,
            ),
            if (kap.hasData)
              'Son fon KAP bildirimi de CROC değerlendirmesine dahil edildi.',
          ];

          return FundCandidateResult(
            fund: fund,
            metrics: metrics,
            intelligence: intelligence,
            suitabilityScore: score,
            suitabilityLabel: _suitabilityEngine.label(score),
            reasons: reasons,
          );
        }),
      );

      final usable = ranked.where((item) => item.suitabilityScore > 0).toList()
        ..sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));

      if (!mounted) return;
      setState(() {
        _loading = false;
        _results = usable;
        _summary = usable.isEmpty
            ? 'Gerçek TEFAS geçmişi yeterli aday bulunamadı.'
            : '${_categoryLabel(query)} grubunda ${usable.length} fon gerçek performans, risk ve erişilebilen KAP verileriyle sıralandı.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Fonlar analiz edilirken veri alınamadı: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFF020605),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF315346),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'CROC bana fon bulsun',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Üç soruya cevap ver. CROC gerçek TEFAS fonlarını performans, risk ve seçtiğin profile göre sıralasın.',
                style: TextStyle(color: Color(0xFF91A69D), height: 1.4),
              ),
              const SizedBox(height: 22),
              _question(
                'Paraya ne kadar süre dokunmayacaksın?',
                ['0-3 AY', '3-12 AY', '1 YIL+'],
                _horizon,
                (value) => setState(() => _horizon = value),
              ),
              const SizedBox(height: 18),
              _question(
                'Dalgalanma seni ne kadar rahatsız eder?',
                ['DUSUK', 'ORTA', 'YUKSEK'],
                _risk,
                (value) => setState(() => _risk = value),
              ),
              const SizedBox(height: 18),
              _question(
                'Ana hedefin ne?',
                ['PARAYI KORU', 'DENGELI BUYUME', 'BUYUME'],
                _goal,
                (value) => setState(() => _goal = value),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _findCandidates,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D7A50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    _loading
                        ? 'Fonlar gerçek verilerle analiz ediliyor...'
                        : 'Bana uygun adayları bul',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Uyum puanı yalnızca mevcut gerçek verilerden hesaplanır. KAP verisi yoksa olumlu varsayım yapılmaz; portföy dağılımı ve makro katmanlar bağlandıkça güven artırılır.',
                style: TextStyle(
                  color: Color(0xFFFFC66D),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFFF6673),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              if (_summary != null) ...[
                const SizedBox(height: 20),
                Text(
                  _summary!,
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._results.take(3).toList().asMap().entries.map(
                  (entry) => _resultTile(entry.value, rank: entry.key + 1),
                ),
                if (_results.length > 3) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    collapsedIconColor: const Color(0xFF70F4AD),
                    iconColor: const Color(0xFF70F4AD),
                    title: Text(
                      'Diğer ${_results.length - 3} adayı gör',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    children:
                        _results.skip(3).map((item) => _resultTile(item)).toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _question(
    String title,
    List<String> options,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final active = selected == option;
            return ChoiceChip(
              selected: active,
              onSelected: (_) => onChanged(option),
              label: Text(option),
              labelStyle: TextStyle(
                color: active ? const Color(0xFF04140D) : const Color(0xFFD6E1DC),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
              selectedColor: const Color(0xFF70F4AD),
              backgroundColor: const Color(0xFF0A2118),
              side: const BorderSide(color: Color(0xFF1E5C43)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _resultTile(FundCandidateResult item, {int? rank}) {
    final metrics = item.metrics;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank == 1 ? const Color(0xFF70F4AD) : const Color(0xFF1E5C43),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.onSelected(item.fund);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (rank != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Color(0xFF70F4AD),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.fund.fundCode,
                    style: const TextStyle(
                      color: Color(0xFF70F4AD),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '%${item.suitabilityScore} ${item.suitabilityLabel}',
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              item.fund.fundName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...item.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• $reason',
                  style: const TextStyle(
                    color: Color(0xFFADC0B8),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '3A ${_percent(metrics.return3M)}  •  6A ${_percent(metrics.return6M)}  •  Risk ${metrics.riskLevel}',
              style: const TextStyle(
                color: Color(0xFF91A69D),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _percent(double? value) {
    if (value == null) return '—';
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}
