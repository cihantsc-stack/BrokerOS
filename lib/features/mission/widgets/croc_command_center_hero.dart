import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../replay/ai_replay_screen.dart';

class CrocCommandCenterHero extends StatefulWidget {
  final List<StockAnalysis> stocks;
  final double totalSmartMoney;

  const CrocCommandCenterHero({
    super.key,
    required this.stocks,
    required this.totalSmartMoney,
  });

  @override
  State<CrocCommandCenterHero> createState() => _CrocCommandCenterHeroState();
}

class _CrocCommandCenterHeroState extends State<CrocCommandCenterHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ranked = List<StockAnalysis>.from(widget.stocks)
      ..sort((a, b) => b.brokerConsensus.compareTo(a.brokerConsensus));

    final StockAnalysis? leader = ranked.isEmpty ? null : ranked.first;

    final int confidence = leader == null
        ? 82
        : ((leader.brokerConsensus * .65) +
                  (widget.totalSmartMoney >= 0 ? 24 : 8))
              .round()
              .clamp(0, 99);

    final String mode = confidence >= 82
        ? 'SEÇİCİ ALIM'
        : confidence >= 66
        ? 'TEMKİNLİ İZLE'
        : 'SAVUNMADA KAL';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14252D), Color(0xFF050B10), Color(0xFF071B12)],
        ),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: .30)),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.primary.withValues(alpha: .13),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/croc_ambush.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(.30, -.10),
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF061017)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF030706).withValues(alpha: .98),
                    const Color(0xFF030706).withValues(alpha: .88),
                    const Color(0xFF030706).withValues(alpha: .58),
                  ],
                  stops: const [0, .60, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .18),
                    Colors.black.withValues(alpha: .28),
                    Colors.black.withValues(alpha: .88),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) =>
                  CustomPaint(painter: _BackgroundPainter(_controller.value)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [_CommandBadge(), Spacer(), _LiveBadge()]),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 540;

                    final globe = _GlobalMoneyGlobe(
                      animation: _controller,
                      confidence: confidence,
                    );

                    final content = _CommandContent(
                      mode: mode,
                      confidence: confidence,
                      leader: leader,
                      totalSmartMoney: widget.totalSmartMoney,
                      onReplay: leader == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AiReplayScreen(stock: leader),
                                ),
                              );
                            },
                    );

                    if (compact) {
                      return Column(
                        children: [globe, const SizedBox(height: 12), content],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: globe),
                        const SizedBox(width: 22),
                        Expanded(flex: 6, child: content),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _OpportunityStrip(stocks: ranked.take(3).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandBadge extends StatelessWidget {
  const _CommandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: .24)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: BrokerColors.primary),
          SizedBox(width: 5),
          Text(
            'CROC COMMAND CENTER',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalMoneyGlobe extends StatelessWidget {
  final Animation<double> animation;
  final int confidence;

  const _GlobalMoneyGlobe({required this.animation, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final pulse =
              .72 + ((math.sin(animation.value * math.pi * 2) + 1) * .14);

          return CustomPaint(
            painter: _GlobePainter(
              progress: animation.value,
              confidence: confidence,
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 8,
                  top: 4,
                  child: _HudBox(
                    title: 'KÜRESEL AKIŞ',
                    lines: ['BIST   +1.82', 'DXY    -0.21', 'ALTIN  +0.65'],
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 4,
                  child: _HudBox(
                    title: 'CROC AI',
                    lines: [
                      'GÜVEN  %$confidence',
                      'RİSK   ORTA',
                      'MOD    SEÇİCİ',
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 34,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xD9040B0F),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: BrokerColors.primary.withValues(alpha: .24),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: BrokerColors.primary.withValues(
                              alpha: pulse,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: BrokerColors.primary,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'GLOBAL INTELLIGENCE ENGINE',
                          style: TextStyle(
                            color: BrokerColors.textSoft,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 3,
                  child: Text(
                    'BURSA  ›  İSTANBUL  ›  LONDRA  ›  NEW YORK  ›  TOKYO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BrokerColors.textSoft,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .55,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HudBox extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _HudBox({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xCC040B0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: .20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 7),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                line,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommandContent extends StatelessWidget {
  final String mode;
  final int confidence;
  final StockAnalysis? leader;
  final double totalSmartMoney;
  final VoidCallback? onReplay;

  const _CommandContent({
    required this.mode,
    required this.confidence,
    required this.leader,
    required this.totalSmartMoney,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BUGÜNKÜ PİYASA KARARI',
          style: TextStyle(
            color: BrokerColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          mode,
          style: const TextStyle(
            color: BrokerColors.textMain,
            fontSize: 31,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          leader == null
              ? 'Piyasa taraması tamamlandı. Hacim teyidi gelmeden pozisyon büyütme.'
              : '${leader!.symbol} öne çıkıyor. Kurumsal para akışı '
                    '${totalSmartMoney >= 0 ? 'pozitif' : 'zayıf'}; kırılım teyidi bekleniyor.',
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 13,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _MiniMetric(label: 'GÜVEN', value: '%$confidence'),
            const SizedBox(width: 10),
            _MiniMetric(
              label: 'RİSK',
              value: confidence >= 78 ? 'ORTA' : 'YÜKSEK',
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onReplay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              onReplay == null ? 'ANALİZ BEKLENİYOR' : 'CROC AI ANALİZİ OYNAT',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: BrokerColors.primary,
              disabledBackgroundColor: BrokerColors.primary.withValues(
                alpha: .25,
              ),
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.white.withValues(alpha: .55),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: .5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: .10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: BrokerColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityStrip extends StatelessWidget {
  final List<StockAnalysis> stocks;

  const _OpportunityStrip({required this.stocks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .44),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .09)),
      ),
      child: stocks.isEmpty
          ? const Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: BrokerColors.primary,
                  size: 18,
                ),
                SizedBox(width: 9),
                Text(
                  'FIRSATLAR TARANIYOR',
                  style: TextStyle(
                    color: BrokerColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Icon(
                  Icons.radar_rounded,
                  color: BrokerColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 9),
                const Text(
                  'FIRSATLAR',
                  style: TextStyle(
                    color: BrokerColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      for (int i = 0; i < stocks.length; i++)
                        Text(
                          '${stocks[i].symbol} ${stocks[i].brokerConsensus}',
                          style: TextStyle(
                            color: i == 0
                                ? BrokerColors.primary
                                : BrokerColors.textMain,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
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

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseDot(),
        SizedBox(width: 6),
        Text(
          'AI AKTİF',
          style: TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: BrokerColors.primary,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: BrokerColors.primary, blurRadius: 10)],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;

  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .030)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = -step; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = -step; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final scanY = (size.height + 70) * progress - 35;
    final scan = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          BrokerColors.primary.withValues(alpha: .11),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY, size.width, 58));

    canvas.drawRect(Rect.fromLTWH(0, scanY, size.width, 58), scan);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _GlobePainter extends CustomPainter {
  final double progress;
  final int confidence;

  _GlobePainter({required this.progress, required this.confidence});

  static const green = Color(0xFF39F58B);
  static const cyan = Color(0xFF2BE6D2);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .50, size.height * .49);
    final radius = math.min(size.width * .25, size.height * .31);

    _drawDeepSpace(canvas, size);
    _drawRadar(canvas, center, radius);
    _drawAtmosphere(canvas, center, radius);
    _drawSphere(canvas, center, radius);
    _drawRoutes(canvas, center, radius);
    _drawSatelliteOrbits(canvas, center, radius);
    _drawSweep(canvas, center, radius);
    _drawScore(canvas, center);
  }

  void _drawDeepSpace(Canvas canvas, Size size) {
    final random = math.Random(27);

    for (int i = 0; i < 58; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(progress * math.pi * 2 + i * .73) + 1) / 2;

      canvas.drawCircle(
        Offset(x, y),
        .35 + random.nextDouble() * .75,
        Paint()..color = Colors.white.withValues(alpha: .05 + twinkle * .17),
      );
    }

    final horizonY = size.height * .76;
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, 1),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            green.withValues(alpha: .20),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, horizonY, size.width, 1)),
    );
  }

  void _drawSatelliteOrbits(Canvas canvas, Offset center, double radius) {
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = cyan.withValues(alpha: .20);

    final orbitRect = Rect.fromCenter(
      center: center,
      width: radius * 3.05,
      height: radius * 1.22,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-.26);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(orbitRect, orbitPaint);

    final angle = progress * math.pi * 2;
    final satellite = Offset(
      center.dx + math.cos(angle) * orbitRect.width / 2,
      center.dy + math.sin(angle) * orbitRect.height / 2,
    );

    canvas.drawCircle(
      satellite,
      9,
      Paint()
        ..color = cyan.withValues(alpha: .13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(satellite, 2.6, Paint()..color = Colors.white);

    canvas.drawLine(
      Offset(satellite.dx - 6, satellite.dy),
      Offset(satellite.dx + 6, satellite.dy),
      Paint()
        ..color = cyan.withValues(alpha: .75)
        ..strokeWidth = 1.2,
    );
    canvas.restore();

    final orbitRect2 = Rect.fromCenter(
      center: center,
      width: radius * 2.62,
      height: radius * 1.72,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(.50);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(
      orbitRect2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = green.withValues(alpha: .13),
    );

    final angle2 = -progress * math.pi * 2 * .72 + 1.4;
    final satellite2 = Offset(
      center.dx + math.cos(angle2) * orbitRect2.width / 2,
      center.dy + math.sin(angle2) * orbitRect2.height / 2,
    );

    canvas.drawCircle(satellite2, 2.2, Paint()..color = green);
    canvas.restore();
  }

  void _drawRadar(Canvas canvas, Offset center, double radius) {
    for (final factor in [1.18, 1.42, 1.66]) {
      canvas.drawCircle(
        center,
        radius * factor,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = green.withValues(alpha: .10 / factor),
      );
    }

    final cross = Paint()
      ..color = green.withValues(alpha: .07)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - radius * 1.70, center.dy),
      Offset(center.dx + radius * 1.70, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 1.70),
      Offset(center.dx, center.dy + radius * 1.70),
      cross,
    );
  }

  void _drawAtmosphere(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 1.03,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..color = green.withValues(alpha: .22),
    );
  }

  void _drawSphere(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.32),
          radius: 1.08,
          colors: [
            const Color(0xFF8BFFC0).withValues(alpha: .58),
            green.withValues(alpha: .42),
            const Color(0xFF06371F),
            const Color(0xFF010604),
          ],
          stops: const [0, .24, .63, 1],
        ).createShader(rect),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = green.withValues(alpha: .70),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * .28, center.dy - radius * .30),
        width: radius * .52,
        height: radius * .30,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: .08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * .97),
      math.pi * .56,
      math.pi * .76,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = cyan.withValues(alpha: .42),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = green.withValues(alpha: .20);

    for (final f in [-.72, -.48, -.24, 0.0, .24, .48, .72]) {
      final y = center.dy + radius * f;
      final width = radius * 2 * math.sqrt(math.max(0, 1 - f * f));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: width,
          height: radius * .13,
        ),
        grid,
      );
    }

    final rotation = progress * math.pi * 2;
    for (int i = 0; i < 8; i++) {
      final phase = rotation + i * math.pi / 4;
      final width = radius * (.18 + .70 * math.cos(phase).abs());
      canvas.drawOval(
        Rect.fromCenter(center: center, width: width, height: radius * 2),
        grid,
      );
    }

    _drawContinents(canvas, center, radius, rotation);
    _drawCityLights(canvas, center, radius);
    canvas.restore();
  }

  void _drawContinents(
    Canvas canvas,
    Offset center,
    double radius,
    double rotation,
  ) {
    final shift = math.sin(rotation) * radius * .18;
    final paint = Paint()..color = green.withValues(alpha: .33);

    final europe = Path()
      ..moveTo(center.dx - radius * .39 + shift, center.dy - radius * .40)
      ..lineTo(center.dx - radius * .11 + shift, center.dy - radius * .47)
      ..lineTo(center.dx + radius * .13 + shift, center.dy - radius * .25)
      ..lineTo(center.dx + radius * .02 + shift, center.dy - radius * .03)
      ..lineTo(center.dx - radius * .25 + shift, center.dy - radius * .09)
      ..close();

    final africa = Path()
      ..moveTo(center.dx - radius * .08 + shift, center.dy - radius * .05)
      ..lineTo(center.dx + radius * .23 + shift, center.dy + radius * .09)
      ..lineTo(center.dx + radius * .08 + shift, center.dy + radius * .55)
      ..lineTo(center.dx - radius * .21 + shift, center.dy + radius * .31)
      ..close();

    final asia = Path()
      ..moveTo(center.dx + radius * .13 + shift, center.dy - radius * .35)
      ..lineTo(center.dx + radius * .72 + shift, center.dy - radius * .20)
      ..lineTo(center.dx + radius * .56 + shift, center.dy + radius * .06)
      ..lineTo(center.dx + radius * .25 + shift, center.dy + radius * .18)
      ..lineTo(center.dx + radius * .04 + shift, center.dy - radius * .06)
      ..close();

    canvas.drawPath(europe, paint);
    canvas.drawPath(africa, paint);
    canvas.drawPath(asia, paint);
  }

  void _drawCityLights(Canvas canvas, Offset center, double radius) {
    final random = math.Random(11);

    for (int i = 0; i < 34; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final radial = math.sqrt(random.nextDouble()) * radius * .80;
      final point = Offset(
        center.dx + math.cos(angle) * radial,
        center.dy + math.sin(angle) * radial * .58,
      );

      canvas.drawCircle(
        point,
        .8 + random.nextDouble(),
        Paint()
          ..color = const Color(
            0xFFFFE29A,
          ).withValues(alpha: .26 + random.nextDouble() * .56)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
      );
    }
  }

  void _drawRoutes(Canvas canvas, Offset center, double radius) {
    final nodes = <Offset>[
      Offset(center.dx - radius * .45, center.dy + radius * .06),
      Offset(center.dx - radius * .22, center.dy - radius * .31),
      Offset(center.dx + radius * .03, center.dy - radius * .34),
      Offset(center.dx + radius * .57, center.dy - radius * .10),
      Offset(center.dx + radius * .45, center.dy + radius * .30),
    ];

    for (int i = 1; i < nodes.length; i++) {
      final start = nodes.first;
      final end = nodes[i];
      final control = Offset(
        (start.dx + end.dx) / 2,
        math.min(start.dy, end.dy) - radius * (.35 + i * .04),
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..color = green.withValues(alpha: .16),
      );

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = cyan.withValues(alpha: .62),
      );

      final t = (progress * 1.30 + i * .18) % 1;
      final packet = _quadraticPoint(start, control, end, t);

      canvas.drawCircle(
        packet,
        7,
        Paint()
          ..color = green.withValues(alpha: .16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(packet, 2.4, Paint()..color = Colors.white);
      canvas.drawCircle(packet, 1.1, Paint()..color = green);
    }

    for (int i = 0; i < nodes.length; i++) {
      final pulse = (math.sin(progress * math.pi * 2 + i) + 1) / 2;

      canvas.drawCircle(
        nodes[i],
        9 + pulse * 8,
        Paint()..color = green.withValues(alpha: .04 + pulse * .08),
      );
      canvas.drawCircle(nodes[i], 4.2, Paint()..color = green);
      canvas.drawCircle(nodes[i], 1.5, Paint()..color = Colors.white);
    }
  }

  Offset _quadraticPoint(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  void _drawSweep(Canvas canvas, Offset center, double radius) {
    final angle = progress * math.pi * 2 - math.pi / 2;

    canvas.drawCircle(
      center,
      radius * 1.52,
      Paint()
        ..shader = SweepGradient(
          startAngle: angle - .72,
          endAngle: angle,
          colors: [
            Colors.transparent,
            green.withValues(alpha: .10),
            green.withValues(alpha: .48),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.54)),
    );

    final end = Offset(
      center.dx + math.cos(angle) * radius * 1.52,
      center.dy + math.sin(angle) * radius * 1.52,
    );

    canvas.drawLine(
      center,
      end,
      Paint()
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = green.withValues(alpha: .84),
    );
  }

  void _drawScore(Canvas canvas, Offset center) {
    final score = TextPainter(
      text: TextSpan(
        text: '$confidence',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    score.paint(
      canvas,
      Offset(center.dx - score.width / 2, center.dy - score.height / 2 - 4),
    );

    final label = TextPainter(
      text: const TextSpan(
        text: 'AI SKORU',
        style: TextStyle(
          color: green,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    label.paint(canvas, Offset(center.dx - label.width / 2, center.dy + 18));
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.confidence != confidence;
  }
}
