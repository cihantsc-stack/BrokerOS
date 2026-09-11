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
  bool _detailedMode = false;
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
              _pageHeader(),
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
                if (_detailedMode) ...[
                  const SizedBox(height: 14),
                  _professionalDetail(history, metrics),
                  const SizedBox(height: 14),
                  _dataTransparency(history, metrics),
                ],
                const SizedBox(height: 14),
                _waitingPanel(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final title = Column(
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
            Text(
              _detailedMode
                  ? 'Profesyonel görünüm: gerçek TEFAS verisi, ham metrikler ve veri şeffaflığı.'
                  : 'Basit görünüm: fonu hiç bilmeyen biri için sade ve anlaşılır özet.',
              style: const TextStyle(color: Color(0xFF91A69D), fontSize: 13),
            ),
          ],
        );

        final mode = SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.lightbulb_outline_rounded),
              label: Text('Basit'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.analytics_outlined),
              label: Text('Detaylı'),
            ),
          ],
          selected: {_detailedMode},
          onSelectionChanged: (value) {
            setState(() => _detailedMode = value.first);
          },
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF70F4AD)
                  : const Color(0xFF91A69D),
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 12), mode],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            mode,
          ],
        );
      },
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E5C43)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E5C43)),
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
    final latest = history.prices.isEmpty ? null : history.prices.last;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
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
          const Text(
            'Son fiyat',
            style: TextStyle(color: Color(0xFF91A69D), fontSize: 11),
          ),
          const SizedBox(height: 4),
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

  Widget _beginnerSummary(FundMetricsResult metrics) {
    final risk = metrics.riskLevel;
    final oneYear = metrics.return1Y;
    final oneMonth = metrics.return1M;

    String headline;
    String explanation;
    IconData icon;

    if (!metrics.available) {
      headline = 'Yorum için veri bekleniyor';
      explanation = 'Gerçek fiyat serisi gelmeden sade yorum üretilmez.';
      icon = Icons.hourglass_empty_rounded;
    } else if (risk == 'YUKSEK') {
      headline = 'Dalgalı bir fon';
      explanation =
          'Geçmişte sert iniş çıkışlar yaşamış. Yüksek getiri ihtimali kadar kayıp ihtimali de önemlidir.';
      icon = Icons.warning_amber_rounded;
    } else if (risk == 'ORTA') {
      headline = 'Orta seviyede dalgalanma';
      explanation =
          'Fon tamamen sakin değil. Tek günlük harekete bakmak yerine birkaç aylık tabloyu birlikte değerlendirmek daha sağlıklı.';
      icon = Icons.balance_rounded;
    } else {
      headline = 'Görece daha sakin hareket';
      explanation =
          'Geçmiş fiyat hareketleri daha sınırlı dalgalanmış. Bu yine de gelecekte zarar olmayacağı anlamına gelmez.';
      icon = Icons.shield_outlined;
    }

    final oneYearText = oneYear == null
        ? '1 yıllık veri yok'
        : oneYear >= 0
            ? '1 yılda ${_signedPercent(oneYear)}'
            : '1 yılda ${oneYear.toStringAsFixed(2)}%';
    final oneMonthText = oneMonth == null
        ? '1 aylık veri yok'
        : '1 ayda ${_signedPercent(oneMonth)}';

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
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF103E2C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF70F4AD)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      explanation,
                      style: const TextStyle(
                        color: Color(0xFF9BAEA7),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _plainChip(oneMonthText),
              _plainChip(oneYearText),
              _plainChip('Risk: $risk'),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bu özet yatırım tavsiyesi değildir; gerçek TEFAS verisini anlaşılır dile çevirir.',
            style: TextStyle(color: Color(0xFF71877D), fontSize: 10.5),
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
            final positive = value != null && value >= 0;
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
                        color: value == null
                            ? Colors.white
                            : positive
                                ? const Color(0xFF70F4AD)
                                : const Color(0xFFFF7777),
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
    final plainRisk = switch (metrics.riskLevel) {
      'YUKSEK' => 'Sert dalgalanabilir',
      'ORTA' => 'Orta dalgalanma',
      'DUSUK' => 'Görece daha sakin',
      _ => 'Veri bekleniyor',
    };

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
          if (!_detailedMode)
            _metricRow('Basit anlatım', plainRisk),
          if (_detailedMode) ...[
            _metricRow(
              'Yıllıklandırılmış volatilite',
              _percent(metrics.annualizedVolatility),
            ),
            _metricRow('Maksimum düşüş', _percent(metrics.maxDrawdown)),
            _metricRow('Gözlem sayısı', metrics.observationCount.toString()),
          ],
          const SizedBox(height: 8),
          Text(
            _detailedMode
                ? 'Risk seviyesi gerçek TEFAS fiyat serisinden hesaplanan volatilite ve maksimum düşüşe dayanır.'
                : 'Detaylı görünümü açarsan volatilite ve maksimum düşüş gibi profesyonel metrikleri de görebilirsin.',
            style: const TextStyle(
              color: Color(0xFF789087),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _professionalDetail(
    FundHistoryResult history,
    FundMetricsResult metrics,
  ) {
    final firstDate = history.prices.isEmpty ? null : history.prices.first.date;
    final lastDate = history.prices.isEmpty ? null : history.prices.last.date;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profesyonel Detay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ham metrikler ve hesaplamada kullanılan fiyat serisi bilgileri.',
            style: TextStyle(color: Color(0xFF91A69D), fontSize: 11),
          ),
          const SizedBox(height: 14),
          _metricRow('1A getiri', _percent(metrics.return1M, signed: true)),
          _metricRow('3A getiri', _percent(metrics.return3M, signed: true)),
          _metricRow('6A getiri', _percent(metrics.return6M, signed: true)),
          _metricRow('1Y getiri', _percent(metrics.return1Y, signed: true)),
          _metricRow(
            'Yıllıklandırılmış volatilite',
            _percent(metrics.annualizedVolatility),
          ),
          _metricRow('Maksimum düşüş', _percent(metrics.maxDrawdown)),
          _metricRow('Risk sınıfı', metrics.riskLevel),
          _metricRow('Gözlem', metrics.observationCount.toString()),
          _metricRow(
            'Seri başlangıcı',
            firstDate == null ? 'VERİ YOK' : _date(firstDate),
          ),
          _metricRow(
            'Son gözlem',
            lastDate == null ? 'VERİ YOK' : _date(lastDate),
          ),
        ],
      ),
    );
  }

  Widget _dataTransparency(
    FundHistoryResult history,
    FundMetricsResult metrics,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Veri Şeffaflığı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _metricRow('Kaynak', history.provider),
          _metricRow('Fon durumu', history.status),
          _metricRow('Metrik durumu', metrics.status),
          _metricRow('Periyot', '${history.periodMonths} ay'),
          _metricRow('Gerçek fiyat kaydı', history.prices.length.toString()),
          const SizedBox(height: 10),
          const Text(
            'CROC burada olmayan kurumsal dağılım, fon para akışı veya yatırımcı sınıfı verisini tahmin edip gerçekmiş gibi göstermez.',
            style: TextStyle(
              color: Color(0xFFFFC66D),
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w700,
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
            'Gelişecek Fon Katmanları',
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

  Widget _plainChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2118),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB9CEC5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
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

  String _signedPercent(double value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';

  String _percent(double? value, {bool signed = false}) {
    if (value == null) return 'VERİ YOK';
    if (signed) return _signedPercent(value);
    return '${value.toStringAsFixed(2)}%';
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

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
