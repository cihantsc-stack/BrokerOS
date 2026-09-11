import 'package:flutter/material.dart';

import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../models/data_terminal_quote.dart';
import '../models/institutional_models.dart';
import '../repositories/institutional_repository.dart';

class DataTerminalStockScreen extends StatefulWidget {
  final DataTerminalQuote quote;

  const DataTerminalStockScreen({super.key, required this.quote});

  @override
  State<DataTerminalStockScreen> createState() =>
      _DataTerminalStockScreenState();
}

class _DataTerminalStockScreenState extends State<DataTerminalStockScreen> {
  int _tabIndex = 0;
  bool _loading = true;
  String? _error;
  CrocTechnicalAnalysis? _analysis;

  final InstitutionalRepository _institutionalRepository =
      InstitutionalRepository();

  InstitutionalDataBundle? _institutionalData;

  static const _tabs = [
    'Özet',
    'Derinlik',
    'İşlemler',
    'AKD',
    'Takas',
    'Grafiksel Takas',
    'Teknik',
    'CROC AI',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final source = YahooBistMarketDataSource();

      final results = await Future.wait([
        source.fetch(widget.quote.code, range: '1y', interval: '1d'),
        _institutionalRepository.load(widget.quote.code),
      ]);

      final snapshot = results[0] as dynamic;
      final institutional = results[1] as InstitutionalDataBundle;

      CrocTechnicalAnalysis? analysis;
      final candles = snapshot.candles;

      if (candles.length >= 20) {
        analysis = const CrocTechnicalAnalysisEngine().analyze(candles);
      }

      if (!mounted) return;

      setState(() {
        _analysis = analysis;
        _institutionalData = institutional;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final positive = widget.quote.changePercent >= 0;
    final changeColor = positive
        ? const Color(0xFF70F4AD)
        : const Color(0xFFFF6673);

    return Scaffold(
      backgroundColor: const Color(0xFF020605),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(changeColor),
            _buildTabs(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_tabIndex),
                    child: _buildTabContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color changeColor) {
    final institutional = _institutionalData;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF04100C),
        border: Border(bottom: BorderSide(color: Color(0xFF173E30))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2A1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2B815B)),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.quote.code.characters.take(2).toString(),
              style: const TextStyle(
                color: Color(0xFF70F4AD),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quote.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.quote.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF91A69D),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${widget.quote.price.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: changeColor.withValues(alpha: .35)),
            ),
            child: Text(
              '${widget.quote.changePercent >= 0 ? '+' : ''}'
              '${widget.quote.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: changeColor,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ConnectionBadge(
            connected: institutional?.providerConnected ?? false,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFF06100D),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = index == _tabIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: InkWell(
                onTap: () => setState(() => _tabIndex = index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF103B2A)
                        : const Color(0xFF071712),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF3AC47C)
                          : const Color(0xFF1A4937),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF70F4AD)
                          : const Color(0xFF8FA39A),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildDepth();
      case 2:
        return _buildTrades();
      case 3:
        return _buildAkd();
      case 4:
        return _buildCustody();
      case 5:
        return _buildGraphicalCustody();
      case 6:
        return _buildTechnical();
      case 7:
        return _buildCrocAi();
      default:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    final a = _analysis;
    final institutional = _institutionalData;

    return ListView(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricCard(
              title: 'FİYAT',
              value: '${widget.quote.price.toStringAsFixed(2)} ₺',
              subtitle:
                  '${widget.quote.changePercent >= 0 ? '+' : ''}'
                  '${widget.quote.changePercent.toStringAsFixed(2)}%',
              icon: Icons.payments_rounded,
            ),
            _MetricCard(
              title: 'HACİM',
              value: _compact(widget.quote.volume),
              subtitle: 'Canlı piyasa verisi',
              icon: Icons.bar_chart_rounded,
            ),
            _MetricCard(
              title: 'CROC SKOR',
              value: a == null ? '—' : '${a.score}',
              subtitle: a == null ? 'Hesaplanıyor' : a.decision,
              icon: Icons.auto_awesome_rounded,
            ),
            _MetricCard(
              title: 'KURUMSAL VERİ',
              value: institutional?.providerConnected == true
                  ? 'BAĞLI'
                  : 'BEKLİYOR',
              subtitle: institutional?.providerName ?? 'Hazırlanıyor',
              icon: Icons.account_balance_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProviderStatusCard(data: institutional),
        const SizedBox(height: 12),
        _buildQuickRead(),
      ],
    );
  }

  Widget _buildQuickRead() {
    final a = _analysis;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF06120E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B4938)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CROC HIZLI OKUMA',
            style: TextStyle(
              color: Color(0xFF70F4AD),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const LinearProgressIndicator(color: Color(0xFF70F4AD))
          else if (_error != null)
            Text(_error!, style: const TextStyle(color: Color(0xFFFF6673)))
          else if (a == null)
            const Text(
              'Teknik analiz için yeterli veri bulunamadı.',
              style: TextStyle(color: Color(0xFF91A69D)),
            )
          else ...[
            _InfoLine(label: 'Karar', value: a.decision),
            _InfoLine(
              label: 'Destek / Direnç',
              value:
                  '${a.support.toStringAsFixed(2)} / '
                  '${a.resistance.toStringAsFixed(2)}',
            ),
            _InfoLine(
              label: 'Hedef / Stop',
              value:
                  '${a.target.toStringAsFixed(2)} / '
                  '${a.stop.toStringAsFixed(2)}',
            ),
            _InfoLine(
              label: 'Risk',
              value: '${a.risk} • ATR ${a.atr.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDepth() {
    return _InstitutionalEmptyState(
      icon: Icons.view_stream_rounded,
      title: 'DERİNLİK',
      fields: const [
        'Kademe',
        'Alış fiyatı',
        'Alış lotu',
        'Satış fiyatı',
        'Satış lotu',
      ],
      data: _institutionalData,
    );
  }

  Widget _buildTrades() {
    final data = _institutionalData;

    if (data?.hasTrades == true) {
      return ListView.separated(
        itemCount: data!.trades.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: Color(0xFF173E30)),
        itemBuilder: (context, index) {
          final trade = data.trades[index];

          return _TradeRow(trade: trade);
        },
      );
    }

    return _InstitutionalEmptyState(
      icon: Icons.swap_horiz_rounded,
      title: 'İŞLEMLER',
      fields: const ['Saat', 'Fiyat', 'Lot', 'Alan kurum', 'Satan kurum'],
      data: data,
    );
  }

  Widget _buildAkd() {
    final data = _institutionalData;

    if (data?.hasBrokerFlows == true) {
      return ListView.separated(
        itemCount: data!.brokerFlows.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: Color(0xFF173E30)),
        itemBuilder: (context, index) {
          return _BrokerFlowRow(flow: data.brokerFlows[index]);
        },
      );
    }

    return _InstitutionalEmptyState(
      icon: Icons.account_balance_rounded,
      title: 'ARACI KURUM DAĞILIMI',
      fields: const ['Kurum', 'Alış', 'Satış', 'Net', 'Pay %'],
      data: data,
    );
  }

  Widget _buildCustody() {
    final data = _institutionalData;

    if (data?.hasCustody == true) {
      return ListView.separated(
        itemCount: data!.custody.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: Color(0xFF173E30)),
        itemBuilder: (context, index) {
          return _CustodyRow(position: data.custody[index]);
        },
      );
    }

    return _InstitutionalEmptyState(
      icon: Icons.stacked_bar_chart_rounded,
      title: 'TAKAS',
      fields: const ['Kurum', 'Mevcut lot', 'Önceki lot', 'Değişim', 'Pay %'],
      data: data,
    );
  }

  Widget _buildGraphicalCustody() {
    return _InstitutionalEmptyState(
      icon: Icons.multiline_chart_rounded,
      title: 'GRAFİKSEL TAKAS',
      fields: const ['Kurum seçimi', 'Tarih', 'Lot', 'Pay %', 'Değişim eğrisi'],
      data: _institutionalData,
    );
  }

  Widget _buildTechnical() {
    final a = _analysis;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
      );
    }

    if (a == null) {
      return const _SimpleInfoPanel(
        icon: Icons.query_stats_rounded,
        title: 'Teknik Analiz',
        text: 'Teknik analiz için yeterli geçmiş veri bulunamadı.',
      );
    }

    return ListView(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricCard(
              title: 'RSI',
              value: a.rsi.toStringAsFixed(1),
              subtitle: 'Momentum',
              icon: Icons.speed_rounded,
            ),
            _MetricCard(
              title: 'MACD',
              value: a.macd.toStringAsFixed(2),
              subtitle: 'Sinyal ${a.macdSignal.toStringAsFixed(2)}',
              icon: Icons.multiline_chart_rounded,
            ),
            _MetricCard(
              title: 'EMA20',
              value: a.ema20.toStringAsFixed(2),
              subtitle: 'EMA50 ${a.ema50.toStringAsFixed(2)}',
              icon: Icons.show_chart_rounded,
            ),
            _MetricCard(
              title: 'ATR',
              value: a.atr.toStringAsFixed(2),
              subtitle: a.risk,
              icon: Icons.shield_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LevelTable(analysis: a),
      ],
    );
  }

  Widget _buildCrocAi() {
    final a = _analysis;
    final institutional = _institutionalData;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
      );
    }

    if (a == null) {
      return const _SimpleInfoPanel(
        icon: Icons.auto_awesome_rounded,
        title: 'CROC AI',
        text: 'CROC AI kararı için yeterli teknik veri bulunamadı.',
      );
    }

    final institutionalReady =
        institutional?.providerConnected == true &&
        (institutional!.hasTrades ||
            institutional.hasBrokerFlows ||
            institutional.hasCustody);

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF082417),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF38A96F)),
          ),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF70F4AD), width: 5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${a.score}',
                  style: const TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CROC AI KARARI',
                      style: TextStyle(
                        color: Color(0xFF70F4AD),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      a.decision,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      institutionalReady
                          ? 'Teknik + kurumsal veri birlikte değerlendiriliyor.'
                          : 'Şimdilik teknik veriyle karar üretiliyor. '
                                'Kurumsal veri bağlandığında karar motoruna eklenecek.',
                      style: const TextStyle(
                        color: Color(0xFF9FB2AA),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ProviderStatusCard(data: institutional),
        const SizedBox(height: 12),
        ...a.reasons.map(
          (reason) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFF07130F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF193F31)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF70F4AD),
                  size: 16,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      color: Color(0xFFA4B4AD),
                      fontSize: 10,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _compact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool connected;

  const _ConnectionBadge({required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF70F4AD) : const Color(0xFFFFC857);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 7),
          const SizedBox(width: 6),
          Text(
            connected ? 'KURUMSAL VERİ BAĞLI' : 'KURUMSAL VERİ BEKLİYOR',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderStatusCard extends StatelessWidget {
  final InstitutionalDataBundle? data;

  const _ProviderStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final connected = data?.providerConnected == true;
    final color = connected ? const Color(0xFF70F4AD) : const Color(0xFFFFC857);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            connected ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.providerName ?? 'Kurumsal veri sağlayıcısı',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data?.statusMessage ?? 'Bağlantı durumu kontrol ediliyor.',
                  style: const TextStyle(
                    color: Color(0xFF9BAEA7),
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionalEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> fields;
  final InstitutionalDataBundle? data;

  const _InstitutionalEmptyState({
    required this.icon,
    required this.title,
    required this.fields,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ProviderStatusCard(data: data),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF06120E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1B4938)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF70F4AD), size: 21),
                  const SizedBox(width: 9),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'VERİ ŞEMASI HAZIR',
                style: TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: fields
                    .map(
                      (field) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1A15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF1E4C3A)),
                        ),
                        child: Text(
                          field,
                          style: const TextStyle(
                            color: Color(0xFF9FB2AA),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TradeRow extends StatelessWidget {
  final InstitutionalTrade trade;

  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${trade.price.toStringAsFixed(2)} ₺ • '
        '${trade.quantity.toStringAsFixed(0)} lot',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '${trade.buyer ?? '—'} → ${trade.seller ?? '—'}',
        style: const TextStyle(color: Color(0xFF91A69D)),
      ),
    );
  }
}

class _BrokerFlowRow extends StatelessWidget {
  final BrokerFlow flow;

  const _BrokerFlowRow({required this.flow});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        flow.broker,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        'Alış ${flow.buyAmount.toStringAsFixed(0)} • '
        'Satış ${flow.sellAmount.toStringAsFixed(0)}',
        style: const TextStyle(color: Color(0xFF91A69D)),
      ),
      trailing: Text(
        flow.netAmount.toStringAsFixed(0),
        style: TextStyle(
          color: flow.netAmount >= 0
              ? const Color(0xFF70F4AD)
              : const Color(0xFFFF6673),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CustodyRow extends StatelessWidget {
  final CustodyPosition position;

  const _CustodyRow({required this.position});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        position.broker,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        'Mevcut ${position.currentLots.toStringAsFixed(0)} • '
        'Önceki ${position.previousLots.toStringAsFixed(0)}',
        style: const TextStyle(color: Color(0xFF91A69D)),
      ),
      trailing: Text(
        position.changeLots.toStringAsFixed(0),
        style: TextStyle(
          color: position.changeLots >= 0
              ? const Color(0xFF70F4AD)
              : const Color(0xFFFF6673),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF193F31)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF70F4AD), size: 18),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF899D94),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF91A69D), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF82978E),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTable extends StatelessWidget {
  final CrocTechnicalAnalysis analysis;

  const _LevelTable({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('HEDEF 1', analysis.target),
      ('HEDEF 2', analysis.target2),
      ('HEDEF 3', analysis.target3),
      ('DİRENÇ 1', analysis.resistance),
      ('DİRENÇ 2', analysis.resistance2),
      ('DİRENÇ 3', analysis.resistance3),
      ('DESTEK 1', analysis.support),
      ('DESTEK 2', analysis.support2),
      ('DESTEK 3', analysis.support3),
      ('STOP', analysis.stop),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF06120E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B4938)),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.$1,
                        style: const TextStyle(
                          color: Color(0xFF91A69D),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      row.$2.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SimpleInfoPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _SimpleInfoPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 640,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF07130F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF193F31)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF70F4AD), size: 32),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF91A69D),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
