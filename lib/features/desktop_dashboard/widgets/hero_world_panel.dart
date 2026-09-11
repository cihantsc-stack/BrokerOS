import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/glossary/interactive_glossary_text.dart';

class HeroWorldPanel extends StatefulWidget {
  const HeroWorldPanel({super.key});

  static const green = Color(0xFF51F39A);
  static const panel = Color(0xE8071512);
  static const border = Color(0xFF174737);

  @override
  State<HeroWorldPanel> createState() => _HeroWorldPanelState();
}

class _HeroWorldPanelState extends State<HeroWorldPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 820;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF020A08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HeroWorldPanel.border),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'images/dashboard/global_engine_hero.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x44000000),
                      Color(0x00000000),
                      Color(0xA8000504),
                    ],
                    stops: [0, .58, 1],
                  ),
                ),
              ),

              // Görseldeki eski üst yazıyı kapat.
              Positioned(
                left: 0,
                top: 0,
                width: c.maxWidth * .38,
                height: 27,
                child: Container(color: const Color(0xF5020A08)),
              ),

              // Görseldeki BURSA yazısını kapat.
              Positioned(
                left: c.maxWidth * .565,
                top: c.maxHeight * .59,
                width: 130,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xF0030C09),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF030C09),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Türkiye merkezli hareketli radar.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, _) => CustomPaint(
                      painter: _WorldScanPainter(progress: _controller.value),
                    ),
                  ),
                ),
              ),

              // Küçültülmüş sol kartlar.
              Positioned(
                left: compact ? 10 : 16,
                top: compact ? 34 : 40,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoCard(
                      title: 'KÜRESEL PARA AKIŞI',
                      value: 'VERİ BEKLENİYOR',
                      subtitle: 'Doğrulanmış akış verisi bağlı değil',
                      icon: Icons.show_chart_rounded,
                    ),
                    SizedBox(height: 8),
                    _InfoCard(
                      title: 'SMART MONEY GÜCÜ',
                      value: 'VERİ BEKLENİYOR',
                      subtitle: 'Kurumsal veri sağlayıcısı bekleniyor',
                      icon: Icons.stacked_line_chart_rounded,
                      progress: 0,
                    ),
                  ],
                ),
              ),

              // Türkiye etiketi.
              Align(
                alignment: const Alignment(.12, .20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE6051611),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: HeroWorldPanel.green.withValues(alpha: .8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HeroWorldPanel.green.withValues(alpha: .25),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: const Text(
                    'TÜRKİYE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 18,
                right: 18,
                bottom: 12,
                child: Row(
                  children: [
                    const _LiveDot(),
                    const SizedBox(width: 8),
                    Text(
                      'CANLI AKIŞ   •   47 PAZAR   •   1.284 VERİ NOKTASI   •   7/24 ANALİZ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .68),
                        fontSize: compact ? 8 : 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: HeroWorldPanel.panel,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: HeroWorldPanel.border),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'AKIŞ HARİTASI',
                            style: TextStyle(
                              color: Color(0xFFAABCB5),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 7),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 12,
                            color: HeroWorldPanel.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorldScanPainter extends CustomPainter {
  final double progress;

  _WorldScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final green = HeroWorldPanel.green;

    // Türkiye / Anadolu merkezi
    final center = Offset(size.width * .585, size.height * .535);

    // Radar halkaları
    for (var i = 1; i <= 4; i++) {
      final phase = (progress + i * .18) % 1;

      canvas.drawCircle(
        center,
        18 + phase * 78,
        Paint()
          ..color = green.withValues(alpha: (1 - phase) * .20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    final targets = <Offset>[
      Offset(size.width * .25, size.height * .42), // Amerika
      Offset(size.width * .43, size.height * .31), // Londra
      Offset(size.width * .57, size.height * .34), // Avrupa
      Offset(size.width * .82, size.height * .43), // Tokyo
      Offset(size.width * .79, size.height * .72), // Singapur
    ];

    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];

      final path = Path()..moveTo(center.dx, center.dy);

      final mid = Offset(
        (center.dx + target.dx) / 2,
        math.min(center.dy, target.dy) - size.height * (.10 + i * .008),
      );

      path.quadraticBezierTo(mid.dx, mid.dy, target.dx, target.dy);

      canvas.drawPath(
        path,
        Paint()
          ..color = green.withValues(alpha: .46)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.25,
      );

      final pulse = .55 + math.sin(progress * math.pi * 2 + i) * .35;

      canvas.drawCircle(
        target,
        3.5 + pulse * 2,
        Paint()
          ..color = green.withValues(alpha: .9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Dönen radar ışını
    final angle = -math.pi * .9 + progress * math.pi * 2;

    final length = math.min(size.width, size.height) * .60;

    final spread = .13;

    final p1 =
        center +
        Offset(math.cos(angle - spread), math.sin(angle - spread)) * length;

    final p2 =
        center +
        Offset(math.cos(angle + spread), math.sin(angle + spread)) * length;

    final beam = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(
      beam,
      Paint()
        ..shader = RadialGradient(
          colors: [
            green.withValues(alpha: .25),
            green.withValues(alpha: .07),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: length)),
    );

    // Türkiye merkez ışığı
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = green
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _WorldScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double? progress;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: HeroWorldPanel.panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: HeroWorldPanel.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InteractiveGlossaryText(
            title,
            style: const TextStyle(
              color: Color(0xFFA8BBB3),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: HeroWorldPanel.green,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF8DA098), fontSize: 8),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: progress,
                backgroundColor: const Color(0xFF1B2B26),
                valueColor: const AlwaysStoppedAnimation(HeroWorldPanel.green),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Icon(icon, size: 15, color: HeroWorldPanel.green),
          ],
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: HeroWorldPanel.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: HeroWorldPanel.green.withValues(alpha: .7),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}
