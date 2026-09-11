import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';

class AiReplayScreen extends StatefulWidget {
  final StockAnalysis stock;

  const AiReplayScreen({super.key, required this.stock});

  @override
  State<AiReplayScreen> createState() => _AiReplayScreenState();
}

class _AiReplayScreenState extends State<AiReplayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _playing = true;

  static const _steps = [
    (
      'Piyasa taraması başladı',
      'Fiyat yapısı ve hacim dengesi analiz ediliyor.',
    ),
    ('İlk iz bulundu', 'Kurumsal para akışı ortalamanın üzerine çıktı.'),
    ('Momentum güçleniyor', 'RSI ve MACD aynı yönde teyit üretiyor.'),
    ('Kırılım doğrulandı', 'Hacim desteğiyle direnç bölgesi aşıldı.'),
    ('CROC AI kararı', 'Risk kontrollü ilk pozisyon bölgesi oluştu.'),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() => _playing = false);
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_controller.isAnimating) {
        _controller.stop();
        _playing = false;
      } else {
        if (_controller.isCompleted) _controller.reset();
        _controller.forward();
        _playing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrokerColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final step = (_controller.value * _steps.length).floor().clamp(
              0,
              _steps.length - 1,
            );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.stock.symbol} · CROC AI REPLAY',
                              style: const TextStyle(
                                color: BrokerColors.textMain,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'AI kararının oluşumunu adım adım izle',
                              style: TextStyle(
                                color: BrokerColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: BrokerColors.primary.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: BrokerColors.primary.withValues(alpha: .22),
                          ),
                        ),
                        child: Text(
                          '%${widget.stock.brokerConsensus}',
                          style: const TextStyle(
                            color: BrokerColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF101A23), Color(0xFF070B10)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: BrokerColors.border),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ReplayChartPainter(
                                progress: _controller.value,
                                score: widget.stock.brokerConsensus,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            right: 18,
                            top: 18,
                            child: Row(
                              children: [
                                _StatusPill(label: '1G', active: true),
                                const SizedBox(width: 7),
                                const _StatusPill(label: 'RSI', active: false),
                                const SizedBox(width: 7),
                                const _StatusPill(label: 'MACD', active: false),
                                const Spacer(),
                                Text(
                                  widget.stock.lastPrice?.toStringAsFixed(2) ??
                                      widget.stock.entry.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: BrokerColors.textMain,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xF20B1118),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: BrokerColors.primary.withValues(
                                    alpha: .25,
                                  ),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 24,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: BrokerColors.crocGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      step == _steps.length - 1
                                          ? Icons.check_rounded
                                          : Icons.auto_awesome_rounded,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _steps[step].$1,
                                          style: const TextStyle(
                                            color: BrokerColors.textMain,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _steps[step].$2,
                                          style: const TextStyle(
                                            color: BrokerColors.textSoft,
                                            fontSize: 12,
                                            height: 1.35,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            minHeight: 8,
                            backgroundColor: BrokerColors.cardSoft,
                            valueColor: const AlwaysStoppedAnimation(
                              BrokerColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      FilledButton.icon(
                        onPressed: _toggle,
                        icon: Icon(
                          _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(_playing ? 'DURAKLAT' : 'OYNA'),
                        style: FilledButton.styleFrom(
                          backgroundColor: BrokerColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusPill({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? BrokerColors.primary.withValues(alpha: .12)
            : Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? BrokerColors.primary.withValues(alpha: .28)
              : Colors.white.withValues(alpha: .07),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? BrokerColors.primary : BrokerColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReplayChartPainter extends CustomPainter {
  final double progress;
  final int score;

  _ReplayChartPainter({required this.progress, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(18, 78, size.width - 36, size.height - 210);
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .045)
      ..strokeWidth = 1;
    for (var i = 0; i <= 5; i++) {
      final y = chart.top + chart.height * i / 5;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    for (var i = 0; i <= 8; i++) {
      final x = chart.left + chart.width * i / 8;
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), grid);
    }

    final count = 54;
    final visible = math.max(1, (count * progress).floor());
    final candleWidth = chart.width / count * .54;
    final rng = math.Random(42 + score);
    double price = 100;
    final candles = <({double open, double close, double high, double low})>[];
    for (var i = 0; i < count; i++) {
      final open = price;
      final drift = i < 17
          ? -.10
          : i < 31
          ? .18
          : i < 42
          ? .55
          : .28;
      final close = open + drift + (rng.nextDouble() - .48) * 2.3;
      final high = math.max(open, close) + rng.nextDouble() * 1.3;
      final low = math.min(open, close) - rng.nextDouble() * 1.3;
      candles.add((open: open, close: close, high: high, low: low));
      price = close;
    }
    final lows = candles.map((e) => e.low).reduce(math.min);
    final highs = candles.map((e) => e.high).reduce(math.max);
    double yFor(double value) =>
        chart.bottom - ((value - lows) / (highs - lows)) * chart.height;

    for (var i = 0; i < visible; i++) {
      final c = candles[i];
      final x = chart.left + (i + .5) * chart.width / count;
      final up = c.close >= c.open;
      final paint = Paint()..color = up ? BrokerColors.green : BrokerColors.red;
      canvas.drawLine(
        Offset(x, yFor(c.high)),
        Offset(x, yFor(c.low)),
        paint..strokeWidth = 1.2,
      );
      final top = yFor(math.max(c.open, c.close));
      final bottom = yFor(math.min(c.open, c.close));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - candleWidth / 2,
            top,
            candleWidth,
            math.max(2, bottom - top),
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }

    if (progress > .28) {
      final zonePaint = Paint()
        ..color = BrokerColors.blue.withValues(alpha: .10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            chart.left + chart.width * .26,
            chart.top + chart.height * .58,
            chart.width * .23,
            34,
          ),
          const Radius.circular(8),
        ),
        zonePaint,
      );
    }
    if (progress > .50) {
      final trend = Paint()
        ..color = BrokerColors.orange
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(chart.left + chart.width * .34, chart.bottom - 28),
        Offset(chart.left + chart.width * .78, chart.top + 48),
        trend,
      );
    }
    if (progress > .72) {
      final x = chart.left + chart.width * .74;
      final y = chart.top + chart.height * .34;
      final glow = Paint()..color = BrokerColors.primary.withValues(alpha: .20);
      canvas.drawCircle(Offset(x, y), 20, glow);
      canvas.drawCircle(Offset(x, y), 7, Paint()..color = BrokerColors.primary);
      final label = TextPainter(
        text: const TextSpan(
          text: 'KIRILIM',
          style: TextStyle(
            color: BrokerColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x + 12, y - 7));
    }
    if (progress > .90) {
      final buyX = chart.left + chart.width * .88;
      final buyY = chart.top + chart.height * .18;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(buyX, buyY), width: 68, height: 30),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, Paint()..color = BrokerColors.primary);
      final text = TextPainter(
        text: const TextSpan(
          text: 'AL',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(buyX - text.width / 2, buyY - text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ReplayChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.score != score;
}
