import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data_foundation/market/historical_candle.dart';
import '../../../core/data_foundation/market/historical_market_data_service.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

enum AiChartRange {
  oneDay('1G', 34),
  fiveDays('5G', 42),
  oneMonth('1A', 58),
  threeMonths('3A', 68),
  sixMonths('6A', 76),
  oneYear('1Y', 84);

  final String label;
  final int candleCount;
  const AiChartRange(this.label, this.candleCount);
}

class AiTechnicalTerminal extends StatefulWidget {
  final StockAnalysis stock;

  const AiTechnicalTerminal({super.key, required this.stock});

  @override
  State<AiTechnicalTerminal> createState() => _AiTechnicalTerminalState();
}

class _AiTechnicalTerminalState extends State<AiTechnicalTerminal> {
  AiChartRange _range = AiChartRange.oneMonth;
  bool _showAiPattern = true;
  bool _showRsi = true;
  bool _showMacd = true;
  final HistoricalMarketDataService _historyService =
      HistoricalMarketDataService();
  HistoricalSeriesResult? _series;
  bool _loadingSeries = false;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  @override
  void didUpdateWidget(covariant AiTechnicalTerminal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stock.symbol != widget.stock.symbol) {
      _series = null;
      _loadSeries();
    }
  }

  String get _interval {
    switch (_range) {
      case AiChartRange.oneDay:
        return '5min';
      case AiChartRange.fiveDays:
        return '30min';
      case AiChartRange.oneMonth:
        return '2h';
      case AiChartRange.threeMonths:
        return '1day';
      case AiChartRange.sixMonths:
        return '1day';
      case AiChartRange.oneYear:
        return '1week';
    }
  }

  Future<void> _loadSeries() async {
    if (_loadingSeries) return;
    setState(() => _loadingSeries = true);
    final price = widget.stock.lastPrice ?? widget.stock.entry;
    final result = await _historyService.fetch(
      symbol: widget.stock.symbol,
      interval: _interval,
      outputSize: _range.candleCount,
      fallbackPrice: price,
    );
    if (!mounted) return;
    setState(() {
      _series = result;
      _loadingSeries = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.stock.lastPrice ?? widget.stock.entry;
    final change = widget.stock.dailyChange ?? 0;
    final support = math.min(widget.stock.entry, price * 0.985);
    final resistance = math.max(widget.stock.target1, price * 1.045);
    final target = math.max(widget.stock.target2, resistance * 1.047);
    final stop = widget.stock.stop;
    final chartData = _series == null
        ? _AiCandleFactory.create(
            symbol: widget.stock.symbol,
            price: price,
            count: _range.candleCount,
            patternEnabled: _showAiPattern,
            resistance: resistance,
            target: target,
          )
        : _AiCandleFactory.fromHistorical(
            candles: _series!.candles,
            patternEnabled: _showAiPattern,
            resistance: resistance,
            target: target,
          );
    final candles = chartData.candles;
    final pattern = chartData.pattern;

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TerminalHeader(stock: widget.stock, price: price, change: change),
          const SizedBox(height: 16),
          _Toolbar(
            selected: _range,
            showAiPattern: _showAiPattern,
            showRsi: _showRsi,
            showMacd: _showMacd,
            onRangeChanged: (value) {
              setState(() {
                _range = value;
                _series = null;
              });
              _loadSeries();
            },
            onPatternChanged: (value) => setState(() => _showAiPattern = value),
            onRsiChanged: (value) => setState(() => _showRsi = value),
            onMacdChanged: (value) => setState(() => _showMacd = value),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final chart = _ChartPanel(
                candles: candles,
                price: price,
                support: support,
                resistance: resistance,
                target: target,
                stop: stop,
                pattern: pattern,
                showPattern: _showAiPattern,
                showRsi: _showRsi,
                showMacd: _showMacd,
                source:
                    _series?.source ??
                    (_loadingSeries ? 'VERİ YÜKLENİYOR' : 'YEREL YEDEK'),
              );
              final analysis = _AiAnalysisPanel(
                stock: widget.stock,
                pattern: pattern,
                support: support,
                resistance: resistance,
                target: target,
                stop: stop,
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: chart),
                    const SizedBox(width: 14),
                    SizedBox(width: 265, child: analysis),
                  ],
                );
              }

              return Column(
                children: [chart, const SizedBox(height: 14), analysis],
              );
            },
          ),
          const SizedBox(height: 14),
          _BottomMetrics(
            support: support,
            resistance: resistance,
            target: target,
            risk: widget.stock.risk,
          ),
        ],
      ),
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  final StockAnalysis stock;
  final double price;
  final double change;

  const _TerminalHeader({
    required this.stock,
    required this.price,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final tone = positive ? BrokerColors.green : BrokerColors.red;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final main = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: BrokerColors.orange,
                  size: 25,
                ),
                const SizedBox(width: 8),
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stock.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BrokerColors.textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${price.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    color: tone,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: tone,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        );

        final score = Container(
          width: compact ? double.infinity : 190,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Skor',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stock.aiScore}/100',
                      style: const TextStyle(
                        color: BrokerColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.aiScore >= 80
                          ? 'Çok Güçlü'
                          : stock.aiScore >= 65
                          ? 'Güçlü'
                          : 'Temkinli',
                      style: const TextStyle(
                        color: BrokerColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: stock.aiScore / 100,
                  strokeWidth: 7,
                  backgroundColor: BrokerColors.primary.withValues(alpha: 0.12),
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [main, const SizedBox(height: 12), score],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: main),
            const SizedBox(width: 16),
            score,
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final AiChartRange selected;
  final bool showAiPattern;
  final bool showRsi;
  final bool showMacd;
  final ValueChanged<AiChartRange> onRangeChanged;
  final ValueChanged<bool> onPatternChanged;
  final ValueChanged<bool> onRsiChanged;
  final ValueChanged<bool> onMacdChanged;

  const _Toolbar({
    required this.selected,
    required this.showAiPattern,
    required this.showRsi,
    required this.showMacd,
    required this.onRangeChanged,
    required this.onPatternChanged,
    required this.onRsiChanged,
    required this.onMacdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...AiChartRange.values.map(
          (range) => _ToolChip(
            label: range.label,
            selected: range == selected,
            onTap: () => onRangeChanged(range),
          ),
        ),
        const SizedBox(width: 5),
        _ToolChip(
          icon: Icons.auto_awesome_rounded,
          label: 'AI Formasyon',
          selected: showAiPattern,
          onTap: () => onPatternChanged(!showAiPattern),
        ),
        _ToolChip(
          label: 'RSI',
          selected: showRsi,
          onTap: () => onRsiChanged(!showRsi),
        ),
        _ToolChip(
          label: 'MACD',
          selected: showMacd,
          onTap: () => onMacdChanged(!showMacd),
        ),
      ],
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToolChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? BrokerColors.primary.withValues(alpha: 0.14)
          : BrokerColors.background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? BrokerColors.primary.withValues(alpha: 0.42)
                  : BrokerColors.textSoft.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? BrokerColors.primary
                      : BrokerColors.textSoft,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? BrokerColors.primary
                      : BrokerColors.textSoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final List<_AiCandle> candles;
  final double price;
  final double support;
  final double resistance;
  final double target;
  final double stop;
  final _PatternResult pattern;
  final bool showPattern;
  final bool showRsi;
  final bool showMacd;
  final String source;

  const _ChartPanel({
    required this.candles,
    required this.price,
    required this.support,
    required this.resistance,
    required this.target,
    required this.stop,
    required this.pattern,
    required this.showPattern,
    required this.showRsi,
    required this.showMacd,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorHeight = (showRsi ? 92.0 : 0) + (showMacd ? 105.0 : 0);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: BrokerColors.textSoft.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 5,
            children: [
              _SmallValue('A', candles.last.open),
              _SmallValue('Y', candles.last.high),
              _SmallValue('D', candles.last.low),
              _SmallValue('K', candles.last.close, tone: BrokerColors.primary),
              Text(
                'Hacim ${(candles.last.volume * 72).toStringAsFixed(1)}M',
                style: const TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            source,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 350.0 + indicatorHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: _AiTerminalPainter(
                candles: candles,
                price: price,
                support: support,
                resistance: resistance,
                target: target,
                stop: stop,
                pattern: pattern,
                showPattern: showPattern,
                showRsi: showRsi,
                showMacd: showMacd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallValue extends StatelessWidget {
  final String label;
  final double value;
  final Color? tone;

  const _SmallValue(this.label, this.value, {this.tone});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(color: BrokerColors.textSoft),
          ),
          TextSpan(
            text: value.toStringAsFixed(2),
            style: TextStyle(color: tone ?? BrokerColors.textMain),
          ),
        ],
      ),
    );
  }
}

class _AiAnalysisPanel extends StatelessWidget {
  final StockAnalysis stock;
  final _PatternResult pattern;
  final double support;
  final double resistance;
  final double target;
  final double stop;

  const _AiAnalysisPanel({
    required this.stock,
    required this.pattern,
    required this.support,
    required this.resistance,
    required this.target,
    required this.stop,
  });

  @override
  Widget build(BuildContext context) {
    final decision = stock.decision.toUpperCase();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF0B111A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFB65CFF).withValues(alpha: 0.34),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✦ AI TEKNİK ANALİZ',
                style: TextStyle(
                  color: Color(0xFFD58AFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _AnalysisLine(
                'Formasyon',
                '${pattern.name} (%${pattern.confidence})',
              ),
              _AnalysisLine('Trend', 'Yükseliş Trendi', positive: true),
              _AnalysisLine(
                'Kırılım Gücü',
                pattern.confirmed ? 'Güçlü' : 'Hazırlanıyor',
                positive: pattern.confirmed,
              ),
              const _AnalysisLine('Hacim Analizi', 'Olumlu', positive: true),
              const _AnalysisLine('Momentum', 'Pozitif', positive: true),
              _AnalysisLine('Risk Seviyesi', stock.risk, warning: true),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✦ AI KARARI',
                style: TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                decision,
                style: const TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stock.aiScore >= 80
                    ? 'Güçlü Alım Sinyali'
                    : stock.aiScore >= 65
                    ? 'Seçici İşlem'
                    : 'Temkinli Bekle',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Divider(height: 22, color: Color(0x2235E88B)),
              Text(
                'Hedef: ${target.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Stop-Loss: ${stop.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  color: BrokerColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysisLine extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;
  final bool warning;

  const _AnalysisLine(
    this.label,
    this.value, {
    this.positive = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = warning
        ? BrokerColors.orange
        : positive
        ? BrokerColors.primary
        : BrokerColors.textMain;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            warning
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            size: 14,
            color: tone,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BrokerColors.textSoft, fontSize: 9),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: tone,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomMetrics extends StatelessWidget {
  final double support;
  final double resistance;
  final double target;
  final String risk;

  const _BottomMetrics({
    required this.support,
    required this.resistance,
    required this.target,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 950
            ? 5
            : width >= 600
            ? 3
            : 2;
        final itemWidth = (width - (columns - 1) * 9) / columns;
        final cards = [
          _Metric(
            'TREND',
            'Yükseliş',
            'Kısa ve orta vade pozitif.',
            BrokerColors.primary,
          ),
          _Metric(
            'DESTEK',
            support.toStringAsFixed(2),
            'Güçlü ana seviye',
            BrokerColors.green,
          ),
          _Metric(
            'DİRENÇ',
            resistance.toStringAsFixed(2),
            'Kırılım bölgesi',
            BrokerColors.orange,
          ),
          const _Metric(
            'HACİM',
            'Artan',
            'Kırılım hacmi olumlu',
            BrokerColors.primary,
          ),
          _Metric(
            'RİSK / GETİRİ',
            '1 : 2.8',
            'Risk $risk',
            BrokerColors.primary,
          ),
        ];
        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: cards
              .map((card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color tone;

  const _Metric(this.label, this.value, this.detail, this.tone);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: BrokerColors.textSoft.withValues(alpha: 0.13),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 9,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCandle {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  const _AiCandle(this.open, this.high, this.low, this.close, this.volume);
}

enum _PatternType {
  cupHandle,
  inverseHeadShoulders,
  doubleBottom,
  ascendingTriangle,
  bullFlag,
  risingChannel,
  none,
}

class _PatternResult {
  final _PatternType type;
  final String name;
  final int confidence;
  final double breakout;
  final double target;
  final bool confirmed;
  final String comment;

  const _PatternResult({
    required this.type,
    required this.name,
    required this.confidence,
    required this.breakout,
    required this.target,
    required this.confirmed,
    required this.comment,
  });
}

class _AiChartData {
  final List<_AiCandle> candles;
  final _PatternResult pattern;

  const _AiChartData(this.candles, this.pattern);
}

class _AiCandleFactory {
  static _AiChartData fromHistorical({
    required List<HistoricalCandle> candles,
    required bool patternEnabled,
    required double resistance,
    required double target,
  }) {
    final mapped = candles
        .map((c) => _AiCandle(c.open, c.high, c.low, c.close, c.volume))
        .toList();
    final type = patternEnabled ? _detectPattern(mapped) : _PatternType.none;
    final info = _patternInfo(type);
    final closes = mapped.map((e) => e.close).toList();
    final first = closes.first;
    final last = closes.last;
    final trendStrength = first == 0 ? 0 : ((last - first).abs() / first * 100);
    final confidence = type == _PatternType.none
        ? 44
        : (68 + trendStrength * 2).round().clamp(68, 94).toInt();
    return _AiChartData(
      mapped,
      _PatternResult(
        type: type,
        name: info.$1,
        confidence: confidence,
        breakout: resistance,
        target: target,
        confirmed: type != _PatternType.none && last >= resistance * 0.97,
        comment: info.$2,
      ),
    );
  }

  static _PatternType _detectPattern(List<_AiCandle> candles) {
    if (candles.length < 20) return _PatternType.none;
    final closes = candles.map((e) => e.close).toList();
    final n = closes.length;
    final a = closes[(n * 0.20).floor()];
    final b = closes[(n * 0.40).floor()];
    final c = closes[(n * 0.60).floor()];
    final d = closes[(n * 0.80).floor()];
    final last = closes.last;
    final low1 = closes
        .sublist((n * 0.18).floor(), (n * 0.48).floor())
        .reduce(math.min);
    final low2 = closes
        .sublist((n * 0.52).floor(), (n * 0.82).floor())
        .reduce(math.min);
    final tolerance = math.max(low1, low2) * 0.025;
    if ((low1 - low2).abs() <= tolerance && last > math.max(b, d))
      return _PatternType.doubleBottom;
    if (b < a && c <= b && d > c && last > d)
      return _PatternType.inverseHeadShoulders;
    final highs = candles.map((e) => e.high).toList();
    final recentHighSpread =
        highs.sublist((n * 0.55).floor()).reduce(math.max) -
        highs.sublist((n * 0.55).floor()).reduce(math.min);
    if (recentHighSpread / last < 0.035 && last > a)
      return _PatternType.ascendingTriangle;
    if (last > firstOf(closes) * 1.08 && d < c && last > d)
      return _PatternType.bullFlag;
    if (last > a && d > c && c > b) return _PatternType.risingChannel;
    if (b < a && c < b && d > c && last > a * 0.98)
      return _PatternType.cupHandle;
    return _PatternType.none;
  }

  static double firstOf(List<double> values) => values.first;

  static _AiChartData create({
    required String symbol,
    required double price,
    required int count,
    required bool patternEnabled,
    required double resistance,
    required double target,
  }) {
    final seed = symbol.codeUnits.fold<int>(19, (a, b) => a * 31 + b);
    final random = math.Random(seed + count);
    final types = _PatternType.values;
    final type = patternEnabled
        ? types[seed.abs() % types.length]
        : _PatternType.none;
    final candles = <_AiCandle>[];
    final start = price * 0.90;
    var previous = start;

    for (var i = 0; i < count; i++) {
      final t = i / math.max(1, count - 1);
      final baseline = start + (price - start) * t;
      final shape = _shape(type, t, price);
      final noise = (random.nextDouble() - 0.5) * price * 0.012;
      final open = previous;
      var close = baseline + shape + noise;
      if (i == count - 1) close = price;
      final wick = price * (0.004 + random.nextDouble() * 0.008);
      final high = math.max(open, close) + wick;
      final low = math.min(open, close) - wick;
      final volumeBoost = t > 0.88 && type != _PatternType.none ? 0.32 : 0.0;
      final volume = (0.20 + random.nextDouble() * 0.55 + volumeBoost)
          .clamp(0.15, 1.0)
          .toDouble();
      candles.add(_AiCandle(open, high, low, close, volume));
      previous = close;
    }

    final info = _patternInfo(type);
    final confidence = type == _PatternType.none ? 42 : 72 + seed.abs() % 23;
    return _AiChartData(
      candles,
      _PatternResult(
        type: type,
        name: info.$1,
        confidence: confidence,
        breakout: resistance,
        target: target,
        confirmed:
            type != _PatternType.none &&
            candles.last.close > resistance * 0.955,
        comment: info.$2,
      ),
    );
  }

  static double _shape(_PatternType type, double t, double price) {
    switch (type) {
      case _PatternType.cupHandle:
        if (t > 0.15 && t < 0.72)
          return -math.sin((t - 0.15) / 0.57 * math.pi) * price * 0.075;
        if (t >= 0.72 && t < 0.88)
          return -math.sin((t - 0.72) / 0.16 * math.pi) * price * 0.025;
        if (t >= 0.88) return (t - 0.88) * price * 0.15;
        return 0;
      case _PatternType.inverseHeadShoulders:
        final left =
            -math.exp(-math.pow((t - 0.28) / 0.075, 2)) * price * 0.045;
        final head =
            -math.exp(-math.pow((t - 0.50) / 0.085, 2)) * price * 0.085;
        final right =
            -math.exp(-math.pow((t - 0.70) / 0.075, 2)) * price * 0.045;
        return left + head + right + (t > 0.82 ? (t - 0.82) * price * 0.13 : 0);
      case _PatternType.doubleBottom:
        final first = -math.exp(-math.pow((t - 0.35) / 0.09, 2)) * price * 0.07;
        final second =
            -math.exp(-math.pow((t - 0.68) / 0.09, 2)) * price * 0.068;
        return first + second + (t > 0.82 ? (t - 0.82) * price * 0.12 : 0);
      case _PatternType.ascendingTriangle:
        final compression = math.sin(t * math.pi * 8) * price * 0.035 * (1 - t);
        return compression + (t > 0.86 ? (t - 0.86) * price * 0.14 : 0);
      case _PatternType.bullFlag:
        if (t < 0.35) return t * price * 0.10;
        if (t < 0.78) return (0.35 - t) * price * 0.055;
        return (t - 0.78) * price * 0.13;
      case _PatternType.risingChannel:
        return math.sin(t * math.pi * 5) * price * 0.022;
      case _PatternType.none:
        return math.sin(t * math.pi * 5.5) * price * 0.015 +
            math.sin(t * math.pi * 13) * price * 0.006;
    }
  }

  static (String, String) _patternInfo(_PatternType type) {
    switch (type) {
      case _PatternType.cupHandle:
        return (
          'Fincan - Kulp',
          'Yuvarlak taban ve kısa kulp sonrası kırılım ihtimali izleniyor.',
        );
      case _PatternType.inverseHeadShoulders:
        return (
          'TOBO',
          'Boyun çizgisi üzerinde kapanış ve hacim teyidi aranıyor.',
        );
      case _PatternType.doubleBottom:
        return (
          'Çift Dip',
          'İkinci dip korunuyor; ara tepe üzeri kırılım teyit seviyesi.',
        );
      case _PatternType.ascendingTriangle:
        return (
          'Yükselen Üçgen',
          'Yükselen dipler direnç altında sıkışmayı güçlendiriyor.',
        );
      case _PatternType.bullFlag:
        return (
          'Boğa Bayrağı',
          'Sert yükseliş sonrası kontrollü düzeltme ve devam ihtimali var.',
        );
      case _PatternType.risingChannel:
        return (
          'Yükselen Kanal',
          'Fiyat yükselen kanal içinde; alt bant risk, üst bant hedef bölgesi.',
        );
      case _PatternType.none:
        return (
          'Belirgin Formasyon Yok',
          'Güvenilir geometrik yapı bulunmadı; AI zorla çizim yapmıyor.',
        );
    }
  }
}

class _AiTerminalPainter extends CustomPainter {
  final List<_AiCandle> candles;
  final double price;
  final double support;
  final double resistance;
  final double target;
  final double stop;
  final _PatternResult pattern;
  final bool showPattern;
  final bool showRsi;
  final bool showMacd;

  const _AiTerminalPainter({
    required this.candles,
    required this.price,
    required this.support,
    required this.resistance,
    required this.target,
    required this.stop,
    required this.pattern,
    required this.showPattern,
    required this.showRsi,
    required this.showMacd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 5.0;
    const right = 67.0;
    const top = 8.0;
    final indicatorHeight = (showRsi ? 92.0 : 0) + (showMacd ? 105.0 : 0);
    final chartBottom = size.height - indicatorHeight - 30;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      chartBottom - 45,
    );
    final volume = Rect.fromLTRB(
      left,
      chart.bottom + 8,
      chart.right,
      chartBottom,
    );

    final highs = candles.map((e) => e.high).toList()
      ..addAll([target, resistance, support, stop]);
    final lows = candles.map((e) => e.low).toList()
      ..addAll([target, resistance, support, stop]);
    var maxPrice = highs.reduce(math.max);
    var minPrice = lows.reduce(math.min);
    final pad = (maxPrice - minPrice) * 0.07;
    maxPrice += pad;
    minPrice -= pad;

    double y(double value) =>
        chart.top + (maxPrice - value) / (maxPrice - minPrice) * chart.height;
    final grid = Paint()
      ..color = BrokerColors.textSoft.withValues(alpha: 0.09)
      ..strokeWidth = 1;
    for (var i = 0; i <= 5; i++) {
      final gy = chart.top + chart.height * i / 5;
      canvas.drawLine(Offset(chart.left, gy), Offset(chart.right, gy), grid);
      _text(
        canvas,
        (maxPrice - (maxPrice - minPrice) * i / 5).toStringAsFixed(2),
        Offset(chart.right + 7, gy - 6),
        BrokerColors.textSoft,
        8,
      );
    }
    for (var i = 0; i <= 5; i++) {
      final gx = chart.left + chart.width * i / 5;
      canvas.drawLine(Offset(gx, chart.top), Offset(gx, volume.bottom), grid);
    }

    final space = chart.width / candles.length;
    final body = math.max(2.0, space * 0.62);
    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final x = chart.left + space * i + space / 2;
      final rising = c.close >= c.open;
      final tone = rising ? BrokerColors.green : BrokerColors.red;
      canvas.drawLine(
        Offset(x, y(c.high)),
        Offset(x, y(c.low)),
        Paint()
          ..color = tone
          ..strokeWidth = 1.05,
      );
      final oy = y(c.open);
      final cy = y(c.close);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - body / 2,
            math.min(oy, cy),
            body,
            math.max(1.5, (oy - cy).abs()),
          ),
          const Radius.circular(1),
        ),
        Paint()..color = tone,
      );
      final vh = volume.height * c.volume;
      canvas.drawRect(
        Rect.fromLTWH(x - body / 2, volume.bottom - vh, body, vh),
        Paint()..color = tone.withValues(alpha: 0.38),
      );
    }

    _level(
      canvas,
      chart,
      y(price),
      'ANLIK ${price.toStringAsFixed(2)}',
      BrokerColors.primary,
      false,
    );
    _level(
      canvas,
      chart,
      y(support),
      'DESTEK ${support.toStringAsFixed(2)}',
      BrokerColors.green,
      true,
    );
    _level(
      canvas,
      chart,
      y(resistance),
      'DİRENÇ ${resistance.toStringAsFixed(2)}',
      BrokerColors.orange,
      true,
    );
    _level(
      canvas,
      chart,
      y(stop),
      'STOP ${stop.toStringAsFixed(2)}',
      BrokerColors.red,
      true,
    );
    _level(
      canvas,
      chart,
      y(target),
      'HEDEF ${target.toStringAsFixed(2)}',
      BrokerColors.primary,
      true,
    );

    if (showPattern) {
      _drawDetectedPattern(canvas, chart, y);
    }

    var indicatorTop = chartBottom + 10;
    if (showRsi) {
      _drawRsi(
        canvas,
        Rect.fromLTRB(left, indicatorTop, chart.right, indicatorTop + 76),
      );
      indicatorTop += 92;
    }
    if (showMacd) {
      _drawMacd(
        canvas,
        Rect.fromLTRB(left, indicatorTop, chart.right, indicatorTop + 90),
      );
    }
  }

  void _drawDetectedPattern(
    Canvas canvas,
    Rect chart,
    double Function(double) y,
  ) {
    if (pattern.type == _PatternType.none) {
      _tag(
        canvas,
        'BELİRGİN FORMASYON YOK',
        Offset(chart.left + chart.width * 0.52, chart.top + 18),
        BrokerColors.textSoft,
      );
      return;
    }
    switch (pattern.type) {
      case _PatternType.cupHandle:
        _drawCurvePattern(canvas, chart, y, 0.16, 0.72, 0.90);
        break;
      case _PatternType.inverseHeadShoulders:
        _drawPolylinePattern(canvas, chart, y, [
          0.18,
          0.28,
          0.38,
          0.50,
          0.60,
          0.70,
          0.82,
        ]);
        break;
      case _PatternType.doubleBottom:
        _drawPolylinePattern(canvas, chart, y, [0.22, 0.35, 0.50, 0.68, 0.82]);
        break;
      case _PatternType.ascendingTriangle:
        _drawTriangle(canvas, chart, y);
        break;
      case _PatternType.bullFlag:
        _drawFlag(canvas, chart, y);
        break;
      case _PatternType.risingChannel:
        _drawChannel(canvas, chart, y);
        break;
      case _PatternType.none:
        break;
    }
    final purple = const Color(0xFFB65CFF);
    _tag(
      canvas,
      pattern.name.toUpperCase(),
      Offset(chart.left + chart.width * 0.52, chart.top + 18),
      purple,
    );
    if (pattern.confirmed) {
      _tag(
        canvas,
        'Kırılım teyidi • %${pattern.confidence}',
        Offset(chart.left + chart.width * 0.62, y(resistance) + 16),
        BrokerColors.primary,
      );
    }
  }

  void _drawCurvePattern(
    Canvas canvas,
    Rect chart,
    double Function(double) y,
    double startT,
    double cupEndT,
    double handleEndT,
  ) {
    final purple = const Color(0xFFB65CFF);
    final startIndex = (candles.length * startT).floor();
    final endIndex = (candles.length * handleEndT)
        .floor()
        .clamp(1, candles.length - 1)
        .toInt();
    final path = Path();
    for (var i = startIndex; i <= endIndex; i++) {
      final x = chart.left + chart.width * (i + 0.5) / candles.length;
      final yy = y(candles[i].close);
      if (i == startIndex)
        path.moveTo(x, yy);
      else
        path.lineTo(x, yy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _drawPolylinePattern(
    Canvas canvas,
    Rect chart,
    double Function(double) y,
    List<double> points,
  ) {
    final purple = const Color(0xFFB65CFF);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final index = (points[i] * (candles.length - 1)).round();
      final point = Offset(
        chart.left + chart.width * points[i],
        y(candles[index].close),
      );
      if (i == 0)
        path.moveTo(point.dx, point.dy);
      else
        path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _drawTriangle(Canvas canvas, Rect chart, double Function(double) y) {
    final purple = const Color(0xFFB65CFF);
    final topY = y(resistance * 0.985);
    final leftX = chart.left + chart.width * 0.20;
    final rightX = chart.left + chart.width * 0.88;
    canvas.drawLine(
      Offset(leftX, topY),
      Offset(rightX, topY),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(leftX, y(candles[(candles.length * 0.2).floor()].low)),
      Offset(rightX, topY),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
  }

  void _drawFlag(Canvas canvas, Rect chart, double Function(double) y) {
    final purple = const Color(0xFFB65CFF);
    final x1 = chart.left + chart.width * 0.38;
    final x2 = chart.left + chart.width * 0.78;
    canvas.drawLine(
      Offset(x1, y(candles[(candles.length * 0.38).floor()].high)),
      Offset(x2, y(candles[(candles.length * 0.78).floor()].high)),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(x1, y(candles[(candles.length * 0.38).floor()].low)),
      Offset(x2, y(candles[(candles.length * 0.78).floor()].low)),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
  }

  void _drawChannel(Canvas canvas, Rect chart, double Function(double) y) {
    final purple = const Color(0xFFB65CFF);
    final first = candles.first;
    final last = candles.last;
    canvas.drawLine(
      Offset(chart.left, y(first.low)),
      Offset(chart.right, y(last.low)),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(chart.left, y(first.high * 1.025)),
      Offset(chart.right, y(last.high * 1.025)),
      Paint()
        ..color = purple
        ..strokeWidth = 2,
    );
  }

  void _drawRsi(Canvas canvas, Rect rect) {
    _text(
      canvas,
      'RSI (14)  65.48',
      Offset(rect.left, rect.top),
      const Color(0xFFB65CFF),
      9,
    );
    final top = rect.top + 15;
    final h = rect.height - 15;
    final midPaint = Paint()
      ..color = const Color(0xFFB65CFF).withValues(alpha: 0.16);
    canvas.drawRect(
      Rect.fromLTWH(rect.left, top + h * 0.16, rect.width, h * 0.62),
      midPaint,
    );
    final path = Path();
    for (var i = 0; i < candles.length; i++) {
      final x = rect.left + rect.width * i / (candles.length - 1);
      final rsi =
          52 +
          math.sin(i * 0.28) * 15 +
          (candles[i].close - candles[i].open) / price * 320;
      final yy = top + (80 - rsi.clamp(20, 80)) / 60 * h;
      if (i == 0)
        path.moveTo(x, yy);
      else
        path.lineTo(x, yy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFB65CFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawMacd(Canvas canvas, Rect rect) {
    _text(
      canvas,
      'MACD (12, 26, close)',
      Offset(rect.left, rect.top),
      BrokerColors.textSoft,
      9,
    );
    final top = rect.top + 16;
    final mid = top + (rect.height - 16) / 2;
    canvas.drawLine(
      Offset(rect.left, mid),
      Offset(rect.right, mid),
      Paint()..color = BrokerColors.textSoft.withValues(alpha: 0.2),
    );
    final blue = Path();
    final orange = Path();
    for (var i = 0; i < candles.length; i++) {
      final x = rect.left + rect.width * i / (candles.length - 1);
      final a = math.sin(i * 0.18) * 17 + math.sin(i * 0.06) * 8;
      final b = math.sin((i - 4) * 0.18) * 13 + math.sin(i * 0.06) * 7;
      final y1 = mid - a;
      final y2 = mid - b;
      if (i == 0) {
        blue.moveTo(x, y1);
        orange.moveTo(x, y2);
      } else {
        blue.lineTo(x, y1);
        orange.lineTo(x, y2);
      }
      final hist = a - b;
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          math.min(mid, mid - hist),
          math.max(1.0, rect.width / candles.length * 0.6),
          hist.abs(),
        ),
        Paint()
          ..color = (hist >= 0 ? BrokerColors.green : BrokerColors.red)
              .withValues(alpha: 0.72),
      );
    }
    canvas.drawPath(
      blue,
      Paint()
        ..color = Colors.lightBlueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawPath(
      orange,
      Paint()
        ..color = BrokerColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _level(
    Canvas canvas,
    Rect rect,
    double y,
    String label,
    Color tone,
    bool dashed,
  ) {
    final paint = Paint()
      ..color = tone.withValues(alpha: 0.86)
      ..strokeWidth = 1.1;
    if (dashed) {
      var x = rect.left;
      while (x < rect.right) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 7, rect.right), y),
          paint,
        );
        x += 11;
      }
    } else {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
    _tag(canvas, label, Offset(rect.right + 3, y - 9), tone);
  }

  void _tag(Canvas canvas, String value, Offset offset, Color tone) {
    final tp = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: tone,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, tp.width + 8, tp.height + 6),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, Paint()..color = tone.withValues(alpha: 0.14));
    tp.paint(canvas, Offset(offset.dx + 4, offset.dy + 3));
  }

  void _text(
    Canvas canvas,
    String value,
    Offset offset,
    Color color,
    double size,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _AiTerminalPainter oldDelegate) => true;
}
