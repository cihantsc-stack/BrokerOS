import 'package:flutter/material.dart';

import '../../core/funds/data_sources/tefas_fund_data_source.dart';
import '../../core/funds/engines/fund_metrics_engine.dart';
import '../../core/funds/models/fund_history_result.dart';
import '../../core/funds/models/fund_metrics_result.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  final TextEditingController _controller = TextEditingController(text: 'GBJ');
  final TefasFundDataSource _dataSource = TefasFundDataSource();
  final FundMetricsEngine _metricsEngine = const FundMetricsEngine();

  FundHistoryResult? _history;
  FundMetricsResult? _metrics;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFund('GBJ');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFund([String? rawCode]) async {
    final code = (rawCode ?? _controller.text).trim().toUpperCase();
    if (code.isEmpty || _loading) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    final history = await _dataSource.fetchHistory(code, periodMonths: 12);
    final metrics = _metricsEngine.calculate(history);

    if (!mounted) return;
    setState(() {
      _history = history;
      _metrics = metrics;
      _loading = false;
      _error = history.available ? null : history.status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = _history;
    final metrics = _metrics;

    return Scaffold(
      backgroundColor: const Color(0xFF020605),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fon Merkezi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Önce sonucu gör, istersen ayrıntıya in. Tüm hesaplamalar gerçek TEFAS fiyat serisine dayanır.',
                style: TextStyle(color: Color(0xFF91A69D), fontSize: 13),
              ),
              const SizedBox(height: 18),
              _searchBar(),
              const SizedBox(height: 18),
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null)
                _statusCard(_error!)
              else if (history != null && metrics != null) ...[
                _fundHeader(history),
                const SizedBox(height: 14),
                _beginnerSummary(metrics),
                const SizedBox(height: 14),
                _performanceGrid(metrics),
                const SizedBox(height: 14),
                _riskPanel(metrics),
                const SizedBox(height: 14),
                _detailExpansion(history, metrics),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final field = TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: _loadFund,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: 'Fon kodu: GBJ, MAC, AFT...',
            hintStyle: const TextStyle(color: Color(0xFF668077)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF70F4AD)),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close, color: Color(0xFF668077)),
                  ),
            filled: true,
            fillColor: const Color(0xFF07130F),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E5C43)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF70F4AD)),
            ),
          ),
        );

        final button = FilledButton(
          onPressed: _loading ? null : () => _loadFund(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1D7A50),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
          ),
          child: const Text(
            'İncele',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        );

        if (compact) {
          return Column(
            children: [
              field,
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: button),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: field),
            const SizedBox(width: 10),
            button,
          ],
        );
      },
    );
  }

  Widget _fundHeader(FundHistoryResult history) {
    final latest = history.latest;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF123A2A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  history.fundCode,
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                history.fundName ?? 'Fon adı verisi bekleniyor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            latest == null ? 'Fiyat verisi yok' : '${latest.price.toStringAsFixed(6)} TL',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${history.provider} • ${history.prices.length} gerçek fiyat gözlemi',
            style: const TextStyle(color: Color(0xFF91A69D), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _beginnerSummary(FundMetricsResult metrics) {
    final risk = metrics.riskLevel;
    final oneYear = metrics.return1Y;
    final oneMonth = metrics.return1M;

    final headline = switch (risk) {
      'YUKSEK' => 'Dalgalı bir fon',
      'ORTA' => 'Orta seviyede dalgalanma',
      'DUSUK' => 'Görece daha sakin hareket',
      _ => 'Yorum için veri bekleniyor',
    };

    final explanation = switch (risk) {
      'YUKSEK' =>
        'Geçmişte sert iniş çıkışlar yaşamış. Getiri kadar olası kayıp da önemlidir.',
      'ORTA' =>
        'Fon tamamen sakin değil. Tek günlük harekete değil, birkaç aylık tabloya birlikte bak.',
      'DUSUK' =>
        'Geçmiş fiyat hareketleri daha sınırlı dalgalanmış. Bu, gelecekte zarar olmayacağı anlamına gelmez.',
      _ => 'Gerçek fiyat serisi gelmeden sade yorum üretilmez.',
    };

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kısaca ne görüyoruz?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              color: Color(0xFF70F4AD),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: const TextStyle(
              color: Color(0xFF9BAEA7),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _plainChip(oneMonth == null ? '1 aylık veri yok' : '1 ay ${_signedPercent(oneMonth)}'),
              _plainChip(oneYear == null ? '1 yıllık veri yok' : '1 yıl ${_signedPercent(oneYear)}'),
              _plainChip('Risk: $risk'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceGrid(FundMetricsResult metrics) {
    final items = <MapEntry<String, double?>>[
      MapEntry('1 Ay', metrics.return1M),
      MapEntry('3 Ay', metrics.return3M),
      MapEntry('6 Ay', metrics.return6M),
      MapEntry('1 Yıl', metrics.return1Y),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final value = item.value;
            final color = value == null
                ? Colors.white
                : value >= 0
                    ? const Color(0xFF70F4AD)
                    : const Color(0xFFFF6673);
            return SizedBox(
              width: itemWidth,
              child: _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.key,
                      style: const TextStyle(
                        color: Color(0xFF91A69D),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value == null ? 'VERİ YOK' : _signedPercent(value),
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _riskPanel(FundMetricsResult metrics) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Görünümü',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _metricRow('Risk seviyesi', metrics.riskLevel),
          _metricRow('Yıllıklandırılmış volatilite', _percent(metrics.annualizedVolatility)),
          _metricRow('Maksimum düşüş', _percent(metrics.maxDrawdown)),
          _metricRow('Gözlem sayısı', metrics.observationCount.toString()),
        ],
      ),
    );
  }

  Widget _detailExpansion(
    FundHistoryResult history,
    FundMetricsResult metrics,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF06130F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1C4B39)),
        ),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            iconColor: const Color(0xFF70F4AD),
            collapsedIconColor: const Color(0xFF70F4AD),
            leading: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF70F4AD).withValues(alpha: .08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF70F4AD),
                size: 20,
              ),
            ),
            title: const Text(
              'DETAYLI ANALİZİ GÖR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Performans • risk • veri aralığı • TEFAS kaynağı • gelişmiş fon katmanları',
                style: TextStyle(
                  color: Color(0xFF8FA79D),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: [
              _professionalDetail(history, metrics),
              const SizedBox(height: 12),
              _waitingPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _professionalDetail(
    FundHistoryResult history,
    FundMetricsResult metrics,
  ) {
    final first = history.prices.isEmpty ? null : history.prices.first;
    final last = history.prices.isEmpty ? null : history.prices.last;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profesyonel Detay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _metricRow('1 Ay getiri', _percentSigned(metrics.return1M)),
          _metricRow('3 Ay getiri', _percentSigned(metrics.return3M)),
          _metricRow('6 Ay getiri', _percentSigned(metrics.return6M)),
          _metricRow('1 Yıl getiri', _percentSigned(metrics.return1Y)),
          _metricRow('Yıllık volatilite', _percent(metrics.annualizedVolatility)),
          _metricRow('Maksimum düşüş', _percent(metrics.maxDrawdown)),
          _metricRow('İlk veri tarihi', first == null ? 'VERİ YOK' : _date(first.date)),
          _metricRow('Son veri tarihi', last == null ? 'VERİ YOK' : _date(last.date)),
          _metricRow('Gözlem sayısı', '${metrics.observationCount}'),
          _metricRow('Kaynak', history.provider),
          _metricRow('Durum', metrics.status),
        ],
      ),
    );
  }

  Widget _waitingPanel() {
    return _card(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelişmiş Fon Katmanları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'CROC Fon Skoru: VERİ BEKLENİYOR\nPortföy dağılımı: VERİ BEKLENİYOR\nFon para akışı: VERİ BEKLENİYOR\nSerbest fon / nitelikli yatırımcı sınıflaması: VERİ BEKLENİYOR',
            style: TextStyle(
              color: Color(0xFF9BAEA7),
              fontSize: 13,
              height: 1.7,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Gerçek kaynak bağlanmadan skor veya finansal veri üretilmez.',
            style: TextStyle(
              color: Color(0xFFFFC66D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(String message) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFFC66D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFD6E1DC),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF91A69D)),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2118),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD6E1DC),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _signedPercent(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  String _percent(double? value) =>
      value == null ? 'VERİ YOK' : '${value.toStringAsFixed(2)}%';

  String _percentSigned(double? value) =>
      value == null ? 'VERİ YOK' : _signedPercent(value);

  String _date(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d.$m.${value.year}';
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: child,
    );
  }
}
