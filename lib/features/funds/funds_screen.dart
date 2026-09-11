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
                'Gerçek TEFAS fiyat serisiyle fon performansı ve risk görünümü.',
                style: TextStyle(color: Color(0xFF91A69D), fontSize: 13),
              ),
              const SizedBox(height: 18),
              _searchBar(),
              const SizedBox(height: 18),
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_error != null) ...[
                _statusCard(_error!),
              ] else if (_history != null && _metrics != null) ...[
                _fundHeader(_history!),
                const SizedBox(height: 14),
                _performanceGrid(_metrics!),
                const SizedBox(height: 14),
                _riskPanel(_metrics!),
                const SizedBox(height: 14),
                _waitingPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: _loadFund,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Fon kodu: GBJ, MAC, AFT...',
              hintStyle: const TextStyle(color: Color(0xFF668077)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF70F4AD)),
              filled: true,
              fillColor: const Color(0xFF07130F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF1E5C43)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF1E5C43)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: _loading ? null : () => _loadFund(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1D7A50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
          ),
          child: const Text(
            'İncele',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _fundHeader(FundHistoryResult history) {
    final latest = history.prices.isEmpty ? null : history.prices.last;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  history.fundName ?? 'Fon adı verisi bekleniyor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            latest == null
                ? 'Fiyat verisi yok'
                : '${latest.price.toStringAsFixed(6)} TL',
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

  Widget _performanceGrid(FundMetricsResult metrics) {
    final items = <MapEntry<String, double?>>[
      MapEntry('1 Ay', metrics.return1M),
      MapEntry('3 Ay', metrics.return3M),
      MapEntry('6 Ay', metrics.return6M),
      MapEntry('1 Yıl', metrics.return1Y),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 850 ? 4 : 2;
        final itemWidth = (width - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final value = item.value;
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
                      value == null
                          ? 'VERİ YOK'
                          : '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white,
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
          _metricRow(
            'Yıllıklandırılmış volatilite',
            _percent(metrics.annualizedVolatility),
          ),
          _metricRow('Maksimum düşüş', _percent(metrics.maxDrawdown)),
          _metricRow('Gözlem sayısı', metrics.observationCount.toString()),
          const SizedBox(height: 8),
          const Text(
            'Risk seviyesi yalnızca gerçek TEFAS fiyat serisinden hesaplanan volatilite ve maksimum düşüşe dayanır.',
            style: TextStyle(
              color: Color(0xFF789087),
              fontSize: 11,
              height: 1.4,
            ),
          ),
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
            'CROC Fon Katmanları',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
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
            'Bu alanlarda gerçek kaynak bağlanmadan skor veya finansal veri üretilmez.',
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
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: _card(
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
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF91A69D)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _percent(double? value) =>
      value == null ? 'VERİ YOK' : '${value.toStringAsFixed(2)}%';

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
