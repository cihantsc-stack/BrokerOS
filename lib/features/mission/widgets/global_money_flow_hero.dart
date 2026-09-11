import 'dart:math' as math;

import 'package:flutter/material.dart';

class GlobalMoneyFlowHero extends StatefulWidget {
  final List<dynamic> stocks;
  final double totalSmartMoney;

  const GlobalMoneyFlowHero({
    super.key,
    required this.stocks,
    required this.totalSmartMoney,
  });

  @override
  State<GlobalMoneyFlowHero> createState() => _GlobalMoneyFlowHeroState();
}

class _GlobalMoneyFlowHeroState extends State<GlobalMoneyFlowHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const Color _green = Color(0xFF55F6A5);
  static const Color _darkGreen = Color(0xFF0A2A20);
  static const Color _background = Color(0xFF03100C);
  static const Color _border = Color(0xFF176A4B);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _formattedFlow {
    final value = widget.totalSmartMoney;

    if (value.abs() >= 1000000000) {
      return '${value >= 0 ? '+' : '-'}${(value.abs() / 1000000000).toStringAsFixed(2)}B';
    }

    if (value.abs() >= 1000000) {
      return '${value >= 0 ? '+' : '-'}${(value.abs() / 1000000).toStringAsFixed(0)}M';
    }

    if (value.abs() >= 1000) {
      return '${value >= 0 ? '+' : '-'}${(value.abs() / 1000).toStringAsFixed(0)}K';
    }

    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1000;

        if (compact) {
          return Column(
            children: [
              SizedBox(height: 520, child: _buildFlowMap()),
              const SizedBox(height: 14),
              _buildDecisionPanel(),
            ],
          );
        }

        return SizedBox(
          height: 560,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: _buildFlowMap()),
              const SizedBox(width: 14),
              Expanded(flex: 3, child: _buildDecisionPanel()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowMap() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: GlobalFlowPainter(progress: _controller.value),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.15, 0.18),
                  radius: 1.2,
                  colors: [_green.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapHeader(),
                const Spacer(),
                Align(alignment: Alignment.center, child: _buildTurkeyNode()),
                const Spacer(),
                _buildMapFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLOBAL MONEY FLOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Küresel para hareketleri ve Türkiye piyasasına etkisi',
                style: TextStyle(
                  color: Color(0xFF809A90),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _green.withValues(alpha: 0.35)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LiveDot(),
              SizedBox(width: 8),
              Text(
                'CANLI AKIŞ',
                style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTurkeyNode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xE6112C22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _green.withValues(alpha: 0.9), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.18),
            blurRadius: 35,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _green.withValues(alpha: 0.75),
                  blurRadius: 18,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'TÜRKİYE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'MERKEZ PİYASA DÜĞÜMÜ',
            style: TextStyle(
              color: _green,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _formattedFlow,
            style: const TextStyle(
              color: _green,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Net akıllı para akışı',
            style: TextStyle(color: Color(0xFF8CA198), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFooter() {
    return Row(
      children: [
        Expanded(
          child: _FlowMetric(
            title: 'ABD',
            value: '+1.28B',
            status: 'Giriş',
            positive: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FlowMetric(
            title: 'AVRUPA',
            value: '+0.87B',
            status: 'Giriş',
            positive: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FlowMetric(
            title: 'ASYA',
            value: '-0.42B',
            status: 'Çıkış',
            positive: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FlowMetric(
            title: 'TÜRKİYE',
            value: _formattedFlow,
            status: 'Güçlü giriş',
            positive: widget.totalSmartMoney >= 0,
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionPanel() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border.withValues(alpha: 0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CrocBadge(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Nihai piyasa kararı',
                      style: TextStyle(color: Color(0xFF7E958B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              _LiveDot(),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(19),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: 0.28)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUGÜNKÜ KARAR',
                  style: TextStyle(
                    color: Color(0xFF839A90),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'SEÇİCİ ALIM',
                  style: TextStyle(
                    color: _green,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Güçlü hisselerde kontrollü pozisyonlanma',
                  style: TextStyle(
                    color: Color(0xFFABC0B6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 19),
          const _ConfidenceGauge(value: 92),
          const SizedBox(height: 19),
          _DecisionReason(
            icon: Icons.account_balance_rounded,
            title: 'Kurumsal para',
            value: _formattedFlow,
            positive: widget.totalSmartMoney >= 0,
          ),
          const SizedBox(height: 10),
          const _DecisionReason(
            icon: Icons.auto_graph_rounded,
            title: 'Piyasa momentumu',
            value: 'Pozitif',
            positive: true,
          ),
          const SizedBox(height: 10),
          const _DecisionReason(
            icon: Icons.shield_outlined,
            title: 'Risk seviyesi',
            value: 'Orta',
            positive: true,
          ),
          const SizedBox(height: 10),
          _DecisionReason(
            icon: Icons.radar_rounded,
            title: 'Taranan fırsatlar',
            value: '${widget.stocks.length} hisse',
            positive: true,
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.025),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: const Text(
              'YTD değildir. CROC AI tarafından üretilen kararlar yatırımcının risk profiliyle birlikte değerlendirilmelidir.',
              style: TextStyle(
                color: Color(0xFF70847B),
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowMetric extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final bool positive;

  const _FlowMetric({
    required this.title,
    required this.value,
    required this.status,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF55F6A5) : const Color(0xFFFF6577);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xD90A1B15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF85998F),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: const TextStyle(color: Color(0xFF71857B), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _DecisionReason extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool positive;

  const _DecisionReason({
    required this.icon,
    required this.title,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF55F6A5) : const Color(0xFFFF6577);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF9CAFA6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceGauge extends StatelessWidget {
  final int value;

  const _ConfidenceGauge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          height: 82,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF55F6A5),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  color: Color(0xFF55F6A5),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI GÜVENİ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Sinyaller birbiriyle yüksek oranda uyumlu.',
                style: TextStyle(
                  color: Color(0xFF82968C),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CrocBadge extends StatelessWidget {
  const _CrocBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF55F6A5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55F6A5).withValues(alpha: 0.25),
            blurRadius: 18,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.psychology_alt_rounded,
        color: Color(0xFF03100C),
        size: 26,
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFF55F6A5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF55F6A5).withValues(alpha: 0.7),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class GlobalFlowPainter extends CustomPainter {
  final double progress;

  GlobalFlowPainter({required this.progress});

  static const Color green = Color(0xFF55F6A5);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintWorldShape(canvas, size);
    _paintRadar(canvas, size);
    _paintFlows(canvas, size);
    _paintNodes(canvas, size);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    const gap = 36.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintWorldShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = green.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final continents = <Path>[
      Path()
        ..moveTo(size.width * 0.08, size.height * 0.37)
        ..quadraticBezierTo(
          size.width * 0.15,
          size.height * 0.24,
          size.width * 0.25,
          size.height * 0.31,
        )
        ..quadraticBezierTo(
          size.width * 0.31,
          size.height * 0.39,
          size.width * 0.25,
          size.height * 0.48,
        )
        ..quadraticBezierTo(
          size.width * 0.20,
          size.height * 0.57,
          size.width * 0.13,
          size.height * 0.51,
        )
        ..close(),
      Path()
        ..moveTo(size.width * 0.29, size.height * 0.48)
        ..quadraticBezierTo(
          size.width * 0.37,
          size.height * 0.51,
          size.width * 0.34,
          size.height * 0.67,
        )
        ..quadraticBezierTo(
          size.width * 0.31,
          size.height * 0.79,
          size.width * 0.25,
          size.height * 0.66,
        )
        ..close(),
      Path()
        ..moveTo(size.width * 0.43, size.height * 0.31)
        ..quadraticBezierTo(
          size.width * 0.53,
          size.height * 0.20,
          size.width * 0.70,
          size.height * 0.31,
        )
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.38,
          size.width * 0.76,
          size.height * 0.50,
        )
        ..quadraticBezierTo(
          size.width * 0.63,
          size.height * 0.57,
          size.width * 0.52,
          size.height * 0.47,
        )
        ..close(),
      Path()
        ..moveTo(size.width * 0.76, size.height * 0.63)
        ..quadraticBezierTo(
          size.width * 0.87,
          size.height * 0.58,
          size.width * 0.91,
          size.height * 0.69,
        )
        ..quadraticBezierTo(
          size.width * 0.84,
          size.height * 0.77,
          size.width * 0.76,
          size.height * 0.63,
        )
        ..close(),
    ];

    for (final path in continents) {
      canvas.drawPath(path, paint);
    }
  }

  void _paintRadar(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.56, size.height * 0.52);

    final maxRadius = math.min(size.width, size.height) * 0.32;

    for (int i = 1; i <= 4; i++) {
      final radius = maxRadius * i / 4;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = green.withValues(alpha: 0.055)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final angle = progress * math.pi * 2;

    final radarPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle - 0.65,
        endAngle: angle,
        colors: [Colors.transparent, green.withValues(alpha: 0.18)],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, radarPaint);
  }

  void _paintFlows(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.56, size.height * 0.52);

    final sources = [
      Offset(size.width * 0.12, size.height * 0.37),
      Offset(size.width * 0.26, size.height * 0.27),
      Offset(size.width * 0.43, size.height * 0.30),
      Offset(size.width * 0.76, size.height * 0.31),
      Offset(size.width * 0.88, size.height * 0.52),
      Offset(size.width * 0.79, size.height * 0.71),
      Offset(size.width * 0.30, size.height * 0.70),
    ];

    for (int i = 0; i < sources.length; i++) {
      final source = sources[i];

      final control = Offset(
        (source.dx + center.dx) / 2,
        math.min(source.dy, center.dy) - 50 - (i % 3) * 15,
      );

      final path = Path()
        ..moveTo(source.dx, source.dy)
        ..quadraticBezierTo(control.dx, control.dy, center.dx, center.dy);

      canvas.drawPath(
        path,
        Paint()
          ..color = green.withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      final metric = PathMetricHelper.pointOnQuadratic(
        source,
        control,
        center,
        (progress + i / sources.length) % 1,
      );

      canvas.drawCircle(
        metric,
        4.2,
        Paint()
          ..color = green
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
  }

  void _paintNodes(Canvas canvas, Size size) {
    final nodes = [
      Offset(size.width * 0.12, size.height * 0.37),
      Offset(size.width * 0.26, size.height * 0.27),
      Offset(size.width * 0.43, size.height * 0.30),
      Offset(size.width * 0.76, size.height * 0.31),
      Offset(size.width * 0.88, size.height * 0.52),
      Offset(size.width * 0.79, size.height * 0.71),
      Offset(size.width * 0.30, size.height * 0.70),
    ];

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        8,
        Paint()..color = green.withValues(alpha: 0.08),
      );

      canvas.drawCircle(
        node,
        3.2,
        Paint()..color = green.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlobalFlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PathMetricHelper {
  static Offset pointOnQuadratic(
    Offset start,
    Offset control,
    Offset end,
    double t,
  ) {
    final oneMinusT = 1 - t;

    final x =
        oneMinusT * oneMinusT * start.dx +
        2 * oneMinusT * t * control.dx +
        t * t * end.dx;

    final y =
        oneMinusT * oneMinusT * start.dy +
        2 * oneMinusT * t * control.dy +
        t * t * end.dy;

    return Offset(x, y);
  }
}
