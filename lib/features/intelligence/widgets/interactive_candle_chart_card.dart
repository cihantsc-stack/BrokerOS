import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

enum CandleInterval {
  oneMinute('1 dk'),
  fiveMinutes('5 dk'),
  fifteenMinutes('15 dk'),
  oneHour('1 saat'),
  fourHours('4 saat'),
  oneDay('1 gün');

  final String label;
  const CandleInterval(this.label);
}

enum ChartRange {
  oneDay('1G'),
  fiveDays('5G'),
  oneMonth('1A'),
  threeMonths('3A'),
  sixMonths('6A'),
  oneYear('1Y');

  final String label;
  const ChartRange(this.label);
}

class InteractiveCandleChartCard extends StatefulWidget {
  final StockAnalysis stock;

  const InteractiveCandleChartCard({super.key, required this.stock});

  @override
  State<InteractiveCandleChartCard> createState() =>
      _InteractiveCandleChartCardState();
}

class _InteractiveCandleChartCardState
    extends State<InteractiveCandleChartCard> {
  CandleInterval _interval = CandleInterval.oneHour;
  ChartRange _range = ChartRange.oneMonth;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final currentPrice = widget.stock.lastPrice ?? widget.stock.entry;
    final support = math.min(widget.stock.entry, currentPrice * 0.985);
    final resistance = math.max(widget.stock.target1, currentPrice * 1.018);
    final stop = widget.stock.stop;

    final candles = _CandleFactory.create(
      symbol: widget.stock.symbol,
      interval: _interval,
      range: _range,
      currentPrice: currentPrice,
      support: support,
      resistance: resistance,
    );

    final selectedCandle =
        _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < candles.length
        ? candles[_selectedIndex!]
        : candles.last;

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.candlestick_chart_rounded,
                color: BrokerColors.primary,
                size: 25,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiyat Grafiği',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Mum aralığı ve görüntüleme süresi ayrı seçilir.',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // TradingView mantığı: üstte mum zaman aralığı.
          _SectionLabel(icon: Icons.timer_outlined, label: 'Mum Aralığı'),
          const SizedBox(height: 7),
          _HorizontalSelector<CandleInterval>(
            values: CandleInterval.values,
            selected: _interval,
            labelOf: (value) => value.label,
            onChanged: (value) {
              setState(() {
                _interval = value;
                _selectedIndex = null;
              });
            },
          ),
          const SizedBox(height: 12),
          _PriceSummary(
            currentPrice: currentPrice,
            support: support,
            resistance: resistance,
            stop: stop,
          ),
          const SizedBox(height: 10),
          _OhlcStrip(candle: selectedCandle),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    _updateSelectedCandle(
                      event.localPosition.dx,
                      constraints.maxWidth,
                      candles.length,
                    );
                  },
                  onExit: (_) {
                    setState(() {
                      _selectedIndex = null;
                    });
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _updateSelectedCandle(
                        details.localPosition.dx,
                        constraints.maxWidth,
                        candles.length,
                      );
                    },
                    onHorizontalDragUpdate: (details) {
                      _updateSelectedCandle(
                        details.localPosition.dx,
                        constraints.maxWidth,
                        candles.length,
                      );
                    },
                    child: CustomPaint(
                      painter: _CandlestickPainter(
                        candles: candles,
                        currentPrice: currentPrice,
                        support: support,
                        resistance: resistance,
                        stop: stop,
                        interval: _interval,
                        range: _range,
                        selectedIndex: _selectedIndex,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const _ChartLegend(),
          const SizedBox(height: 13),

          // TradingView mantığı: altta toplam görüntüleme süresi.
          _SectionLabel(
            icon: Icons.date_range_outlined,
            label: 'Görüntüleme Süresi',
          ),
          const SizedBox(height: 7),
          _HorizontalSelector<ChartRange>(
            values: ChartRange.values,
            selected: _range,
            labelOf: (value) => value.label,
            onChanged: (value) {
              setState(() {
                _range = value;
                _selectedIndex = null;
              });
            },
          ),
          const SizedBox(height: 9),
          Text(
            '${_rangeDescription(_range)} • Her mum ${_interval.label}.',
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSelectedCandle(double localX, double width, int candleCount) {
    const leftPadding = 5.0;
    const rightPadding = 64.0;
    final chartWidth = math.max(1.0, width - leftPadding - rightPadding);
    final normalized = ((localX - leftPadding) / chartWidth).clamp(0.0, 0.9999);
    final index = (normalized * candleCount).floor().clamp(0, candleCount - 1);

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  String _rangeDescription(ChartRange range) {
    switch (range) {
      case ChartRange.oneDay:
        return 'Son 1 gün';
      case ChartRange.fiveDays:
        return 'Son 5 gün';
      case ChartRange.oneMonth:
        return 'Son 1 ay';
      case ChartRange.threeMonths:
        return 'Son 3 ay';
      case ChartRange.sixMonths:
        return 'Son 6 ay';
      case ChartRange.oneYear:
        return 'Son 1 yıl';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: BrokerColors.textSoft),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HorizontalSelector<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  const _HorizontalSelector({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: BrokerColors.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: BrokerColors.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: values.map((value) {
            final isSelected = value == selected;
            return Material(
              color: isSelected
                  ? BrokerColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => onChanged(value),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  child: Text(
                    labelOf(value),
                    style: TextStyle(
                      color: isSelected
                          ? BrokerColors.primary
                          : BrokerColors.textSoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final double currentPrice;
  final double support;
  final double resistance;
  final double stop;

  const _PriceSummary({
    required this.currentPrice,
    required this.support,
    required this.resistance,
    required this.stop,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _LevelPill(
          label: 'Anlık',
          value: currentPrice,
          tone: BrokerColors.primary,
        ),
        _LevelPill(label: 'Destek', value: support, tone: BrokerColors.green),
        _LevelPill(
          label: 'Direnç',
          value: resistance,
          tone: BrokerColors.orange,
        ),
        _LevelPill(label: 'Stop-Loss', value: stop, tone: BrokerColors.red),
      ],
    );
  }
}

class _LevelPill extends StatelessWidget {
  final String label;
  final double value;
  final Color tone;

  const _LevelPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: tone.withValues(alpha: 0.16)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(color: BrokerColors.textSoft),
            ),
            TextSpan(
              text: '${value.toStringAsFixed(2)} ₺',
              style: TextStyle(color: tone),
            ),
          ],
        ),
      ),
    );
  }
}

class _OhlcStrip extends StatelessWidget {
  final _Candle candle;

  const _OhlcStrip({required this.candle});

  @override
  Widget build(BuildContext context) {
    final rising = candle.close >= candle.open;
    final tone = rising ? BrokerColors.green : BrokerColors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Wrap(
        spacing: 13,
        runSpacing: 5,
        children: [
          _OhlcValue(label: 'A', value: candle.open),
          _OhlcValue(label: 'Y', value: candle.high),
          _OhlcValue(label: 'D', value: candle.low),
          _OhlcValue(label: 'K', value: candle.close, tone: tone),
          Text(
            rising ? '▲ Yükseliş mumu' : '▼ Düşüş mumu',
            style: TextStyle(
              color: tone,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OhlcValue extends StatelessWidget {
  final String label;
  final double value;
  final Color? tone;

  const _OhlcValue({required this.label, required this.value, this.tone});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
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

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 13,
      runSpacing: 7,
      children: [
        _LegendItem(label: 'Yükseliş', tone: BrokerColors.green),
        _LegendItem(label: 'Düşüş', tone: BrokerColors.red),
        _LegendItem(label: 'Anlık fiyat', tone: BrokerColors.primary),
        _LegendItem(label: 'Destek / Direnç', tone: BrokerColors.orange),
        _LegendItem(label: 'Stop', tone: BrokerColors.red),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color tone;

  const _LegendItem({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Candle {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const _Candle({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class _CandleFactory {
  static List<_Candle> create({
    required String symbol,
    required CandleInterval interval,
    required ChartRange range,
    required double currentPrice,
    required double support,
    required double resistance,
  }) {
    final count = _visibleCandleCount(interval, range);
    final seed = symbol.codeUnits.fold<int>(0, (sum, value) => sum + value);
    final random = math.Random(seed + interval.index * 997 + range.index * 431);

    final priceRange = math.max(resistance - support, currentPrice * 0.04);
    final volatility = priceRange * _volatilityFactor(interval);

    var previousClose = currentPrice - priceRange * 0.18;

    final candles = <_Candle>[];

    for (var i = 0; i < count; i++) {
      final progress = i / math.max(1, count - 1);
      final trendTarget =
          currentPrice - priceRange * 0.18 + priceRange * 0.18 * progress;
      final wave = math.sin((i + seed % 5) * 0.72) * volatility * 0.45;
      final noise = (random.nextDouble() - 0.5) * volatility;

      final open = previousClose;
      var close = trendTarget + wave + noise;

      close = close.clamp(
        support - priceRange * 0.10,
        resistance + priceRange * 0.08,
      );

      final wick = volatility * (0.35 + random.nextDouble() * 0.75);
      final high = math.max(open, close) + wick;
      final low = math.min(open, close) - wick;
      final volume = 0.25 + random.nextDouble() * 0.75;

      candles.add(
        _Candle(open: open, high: high, low: low, close: close, volume: volume),
      );

      previousClose = close;
    }

    final last = candles.last;
    candles[candles.length - 1] = _Candle(
      open: last.open,
      high: math.max(last.high, currentPrice),
      low: math.min(last.low, currentPrice),
      close: currentPrice,
      volume: last.volume,
    );

    return candles;
  }

  static int _visibleCandleCount(CandleInterval interval, ChartRange range) {
    final base = switch (range) {
      ChartRange.oneDay => 24,
      ChartRange.fiveDays => 36,
      ChartRange.oneMonth => 48,
      ChartRange.threeMonths => 54,
      ChartRange.sixMonths => 58,
      ChartRange.oneYear => 60,
    };

    final adjustment = switch (interval) {
      CandleInterval.oneMinute => 0,
      CandleInterval.fiveMinutes => -2,
      CandleInterval.fifteenMinutes => -1,
      CandleInterval.oneHour => 0,
      CandleInterval.fourHours => 2,
      CandleInterval.oneDay => 4,
    };

    return (base + adjustment).clamp(20, 64);
  }

  static double _volatilityFactor(CandleInterval interval) {
    return switch (interval) {
      CandleInterval.oneMinute => 0.040,
      CandleInterval.fiveMinutes => 0.050,
      CandleInterval.fifteenMinutes => 0.060,
      CandleInterval.oneHour => 0.075,
      CandleInterval.fourHours => 0.095,
      CandleInterval.oneDay => 0.125,
    };
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<_Candle> candles;
  final double currentPrice;
  final double support;
  final double resistance;
  final double stop;
  final CandleInterval interval;
  final ChartRange range;
  final int? selectedIndex;

  const _CandlestickPainter({
    required this.candles,
    required this.currentPrice,
    required this.support,
    required this.resistance,
    required this.stop,
    required this.interval,
    required this.range,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 5.0;
    const rightPadding = 64.0;
    const topPadding = 10.0;
    const bottomPadding = 45.0;
    const volumeHeight = 35.0;

    final chartRect = Rect.fromLTRB(
      leftPadding,
      topPadding,
      size.width - rightPadding,
      size.height - bottomPadding - volumeHeight,
    );

    final volumeRect = Rect.fromLTRB(
      chartRect.left,
      chartRect.bottom + 7,
      chartRect.right,
      size.height - bottomPadding,
    );

    final allHighs = candles.map((e) => e.high).toList()
      ..addAll([currentPrice, support, resistance, stop]);
    final allLows = candles.map((e) => e.low).toList()
      ..addAll([currentPrice, support, resistance, stop]);

    var maxPrice = allHighs.reduce(math.max);
    var minPrice = allLows.reduce(math.min);
    final padding = math.max(
      (maxPrice - minPrice) * 0.09,
      currentPrice * 0.005,
    );
    maxPrice += padding;
    minPrice -= padding;

    double yFor(double price) {
      final ratio = (maxPrice - price) / (maxPrice - minPrice);
      return chartRect.top + ratio * chartRect.height;
    }

    final gridPaint = Paint()
      ..color = BrokerColors.textSoft.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );

      final price = maxPrice - (maxPrice - minPrice) * i / 4;
      _drawText(
        canvas,
        price.toStringAsFixed(2),
        Offset(chartRect.right + 7, y - 7),
        BrokerColors.textSoft,
        9,
      );
    }

    final candleSpace = chartRect.width / math.max(1, candles.length);
    final bodyWidth = math.max(2.2, candleSpace * 0.60);

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];
      final x = chartRect.left + candleSpace * i + candleSpace / 2;
      final rising = candle.close >= candle.open;
      final tone = rising ? BrokerColors.green : BrokerColors.red;

      final wickPaint = Paint()
        ..color = tone.withValues(alpha: 0.85)
        ..strokeWidth = 1.2;

      canvas.drawLine(
        Offset(x, yFor(candle.high)),
        Offset(x, yFor(candle.low)),
        wickPaint,
      );

      final openY = yFor(candle.open);
      final closeY = yFor(candle.close);
      final bodyTop = math.min(openY, closeY);
      final bodyHeight = math.max(1.6, (openY - closeY).abs());

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
          const Radius.circular(1.4),
        ),
        Paint()..color = tone,
      );

      final volumeBarHeight = volumeRect.height * candle.volume;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - bodyWidth / 2,
            volumeRect.bottom - volumeBarHeight,
            bodyWidth,
            volumeBarHeight,
          ),
          const Radius.circular(1),
        ),
        Paint()..color = tone.withValues(alpha: 0.32),
      );
    }

    _drawLevel(
      canvas: canvas,
      rect: chartRect,
      y: yFor(currentPrice),
      label: 'ANLIK ${currentPrice.toStringAsFixed(2)}',
      tone: BrokerColors.primary,
      dashed: false,
    );
    _drawLevel(
      canvas: canvas,
      rect: chartRect,
      y: yFor(support),
      label: 'DESTEK ${support.toStringAsFixed(2)}',
      tone: BrokerColors.green,
      dashed: true,
    );
    _drawLevel(
      canvas: canvas,
      rect: chartRect,
      y: yFor(resistance),
      label: 'DİRENÇ ${resistance.toStringAsFixed(2)}',
      tone: BrokerColors.orange,
      dashed: true,
    );
    _drawLevel(
      canvas: canvas,
      rect: chartRect,
      y: yFor(stop),
      label: 'STOP ${stop.toStringAsFixed(2)}',
      tone: BrokerColors.red,
      dashed: true,
    );

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < candles.length) {
      final x = chartRect.left + candleSpace * selectedIndex! + candleSpace / 2;
      final selected = candles[selectedIndex!];

      final crosshair = Paint()
        ..color = BrokerColors.textMain.withValues(alpha: 0.38)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, volumeRect.bottom),
        crosshair,
      );

      final y = yFor(selected.close);
      canvas.drawCircle(
        Offset(x, y),
        3.5,
        Paint()..color = BrokerColors.primary,
      );
    }

    final labels = _bottomLabels(range);
    for (var i = 0; i < labels.length; i++) {
      final ratio = i / math.max(1, labels.length - 1);
      final x = chartRect.left + chartRect.width * ratio;
      _drawText(
        canvas,
        labels[i],
        Offset(x - 10, volumeRect.bottom + 8),
        BrokerColors.textSoft,
        8,
      );
    }

    _drawText(
      canvas,
      'Hacim',
      Offset(chartRect.left, volumeRect.top - 1),
      BrokerColors.textSoft,
      8,
    );
  }

  List<String> _bottomLabels(ChartRange range) {
    return switch (range) {
      ChartRange.oneDay => ['10:00', '12:00', '14:00', '16:00', '18:00'],
      ChartRange.fiveDays => ['Pzt', 'Sal', 'Çar', 'Per', 'Cum'],
      ChartRange.oneMonth => ['1. hf', '2. hf', '3. hf', '4. hf'],
      ChartRange.threeMonths => ['1. ay', '2. ay', '3. ay'],
      ChartRange.sixMonths => ['1. ay', '2. ay', '4. ay', '6. ay'],
      ChartRange.oneYear => ['Oca', 'Mar', 'Haz', 'Eyl', 'Ara'],
    };
  }

  void _drawLevel({
    required Canvas canvas,
    required Rect rect,
    required double y,
    required String label,
    required Color tone,
    required bool dashed,
  }) {
    final paint = Paint()
      ..color = tone.withValues(alpha: 0.85)
      ..strokeWidth = 1.2;

    if (dashed) {
      var x = rect.left;
      while (x < rect.right) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 6, rect.right), y),
          paint,
        );
        x += 10;
      }
    } else {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: tone, fontSize: 8, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final background = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.right + 3,
        y - textPainter.height / 2 - 3,
        60,
        textPainter.height + 6,
      ),
      const Radius.circular(5),
    );

    canvas.drawRRect(background, Paint()..color = tone.withValues(alpha: 0.12));

    textPainter.paint(
      canvas,
      Offset(rect.right + 6, y - textPainter.height / 2),
    );
  }

  void _drawText(
    Canvas canvas,
    String value,
    Offset offset,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
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

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.currentPrice != currentPrice ||
        oldDelegate.support != support ||
        oldDelegate.resistance != resistance ||
        oldDelegate.stop != stop ||
        oldDelegate.interval != interval ||
        oldDelegate.range != range ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
