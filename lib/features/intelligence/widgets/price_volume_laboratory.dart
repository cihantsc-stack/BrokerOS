import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'interactive_candle_chart_card.dart';

class PriceVolumeLaboratory extends StatefulWidget {
  final StockAnalysis stock;

  const PriceVolumeLaboratory({super.key, required this.stock});

  @override
  State<PriceVolumeLaboratory> createState() => _PriceVolumeLaboratoryState();
}

class _PriceVolumeLaboratoryState extends State<PriceVolumeLaboratory> {
  String _period = '1A';

  static const _periods = ['1G', '1H', '1A', '3A'];

  @override
  Widget build(BuildContext context) {
    final data = _buildVolumeData(widget.stock, _period);
    final avg =
        data.fold<double>(0, (sum, item) => sum + item.volume) /
        math.max(1, data.length);
    final latest = data.isEmpty ? 0.0 : data.last.volume;
    final double difference = avg == 0 ? 0.0 : ((latest / avg) - 1.0) * 100.0;
    final unusualCount = data.where((item) => item.volume > avg * 1.45).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InteractiveCandleChartCard(stock: widget.stock),
        const SizedBox(height: 12),
        BrokerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: BrokerColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: BrokerColors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.stock.symbol} Hacim Grafiği',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Fiyat grafiğiyle aynı inceleme dönemi',
                          style: TextStyle(color: BrokerColors.textSoft),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (difference >= 0
                                  ? BrokerColors.green
                                  : BrokerColors.orange)
                              .withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: difference >= 0
                            ? BrokerColors.green
                            : BrokerColors.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final period in _periods)
                    ChoiceChip(
                      label: Text(period),
                      selected: _period == period,
                      onSelected: (_) => setState(() => _period = period),
                      selectedColor: BrokerColors.primary.withValues(
                        alpha: 0.18,
                      ),
                      backgroundColor: BrokerColors.background.withValues(
                        alpha: 0.70,
                      ),
                      side: BorderSide(
                        color: _period == period
                            ? BrokerColors.primary
                            : BrokerColors.border,
                      ),
                      labelStyle: TextStyle(
                        color: _period == period
                            ? BrokerColors.primary
                            : BrokerColors.textSoft,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 190,
                width: double.infinity,
                child: CustomPaint(
                  painter: _VolumePainter(points: data, average: avg),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Metric(label: 'Son hacim', value: _compact(latest)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metric(label: 'Ortalama', value: _compact(avg)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Metric(
                      label: 'Olağandışı',
                      value: '$unusualCount dönem',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CrocVolumeComment(
                symbol: widget.stock.symbol,
                difference: difference,
                unusualCount: unusualCount,
                technicalScore: widget.stock.technicalScore,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static List<_VolumePoint> _buildVolumeData(
    StockAnalysis stock,
    String period,
  ) {
    final count = switch (period) {
      '1G' => 18,
      '1H' => 20,
      '3A' => 32,
      _ => 26,
    };
    final seed =
        stock.symbol.codeUnits.fold<int>(0, (a, b) => a + b) +
        stock.technicalScore +
        stock.smartMoneyScore;
    final random = math.Random(seed + period.codeUnitAt(0));
    final trend = (stock.technicalScore - 50) / 100;

    return List.generate(count, (index) {
      final wave = math.sin(index / 2.4) * 0.18;
      final drift = index / count * trend;
      final spike = index == count - 1 || index == count - 7
          ? 0.32 + random.nextDouble() * 0.40
          : 0.0;
      final volume =
          76000000 * (0.72 + random.nextDouble() * 0.55 + wave + drift + spike);
      final positive = random.nextDouble() > (0.48 - trend / 3);
      return _VolumePoint(math.max(8000000.0, volume).toDouble(), positive);
    });
  }

  static String _compact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)} Mr';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Mn';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} B';
    }
    return value.toStringAsFixed(0);
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CrocVolumeComment extends StatelessWidget {
  final String symbol;
  final double difference;
  final int unusualCount;
  final int technicalScore;

  const _CrocVolumeComment({
    required this.symbol,
    required this.difference,
    required this.unusualCount,
    required this.technicalScore,
  });

  @override
  Widget build(BuildContext context) {
    final strong = difference >= 25 && technicalScore >= 55;
    final weak = difference <= -20;
    final text = strong
        ? '$symbol fiyat hareketi ortalamanın üzerindeki hacimle destekleniyor. Hacim teyidi güçlü; yine de destek ve stop seviyeleri korunmalı.'
        : weak
        ? '$symbol fiyat hareketinde hacim zayıflaması var. Yeni işlem için hacmin yeniden ortalama üzerine çıkması daha sağlıklı.'
        : '$symbol hacmi normal bantta. $unusualCount olağandışı dönem tespit edildi; fiyat yönüyle birlikte izlenmeli.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt_rounded, color: BrokerColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BrokerColors.textMain,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumePainter extends CustomPainter {
  final List<_VolumePoint> points;
  final double average;

  const _VolumePainter({required this.points, required this.average});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxValue = points.map((e) => e.volume).reduce(math.max) * 1.12;
    final gap = size.width / points.length;
    final barWidth = math.max(3.0, gap * 0.58);
    final gridPaint = Paint()
      ..color = BrokerColors.border.withValues(alpha: 0.50)
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final height = (point.volume / maxValue) * (size.height - 14);
      final x = gap * i + (gap - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - height, barWidth, height),
        const Radius.circular(3),
      );
      final paint = Paint()
        ..color = (point.positive ? BrokerColors.green : BrokerColors.orange)
            .withValues(alpha: point.volume > average * 1.45 ? 0.95 : 0.62);
      canvas.drawRRect(rect, paint);
    }

    final averageY = size.height - (average / maxValue) * (size.height - 14);
    final averagePaint = Paint()
      ..color = BrokerColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, averageY),
      Offset(size.width, averageY),
      averagePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _VolumePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.average != average;
  }
}

class _VolumePoint {
  final double volume;
  final bool positive;

  const _VolumePoint(this.volume, this.positive);
}
