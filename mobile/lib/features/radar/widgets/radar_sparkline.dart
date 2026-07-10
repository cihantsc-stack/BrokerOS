import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class RadarSparkline extends StatelessWidget {
  final bool up;

  const RadarSparkline({
    super.key,
    required this.up,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarSparklinePainter(up: up),
      child: const SizedBox.expand(),
    );
  }
}

class _RadarSparklinePainter extends CustomPainter {
  final bool up;

  const _RadarSparklinePainter({required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = BrokerColors.borderSoft.withOpacity(.40)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = up
        ? [
            Offset(0, size.height * .72),
            Offset(size.width * .14, size.height * .62),
            Offset(size.width * .28, size.height * .66),
            Offset(size.width * .42, size.height * .47),
            Offset(size.width * .56, size.height * .54),
            Offset(size.width * .70, size.height * .32),
            Offset(size.width * .84, size.height * .38),
            Offset(size.width, size.height * .18),
          ]
        : [
            Offset(0, size.height * .30),
            Offset(size.width * .14, size.height * .42),
            Offset(size.width * .28, size.height * .35),
            Offset(size.width * .42, size.height * .50),
            Offset(size.width * .56, size.height * .48),
            Offset(size.width * .70, size.height * .63),
            Offset(size.width * .84, size.height * .58),
            Offset(size.width, size.height * .74),
          ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    final color = up ? BrokerColors.primary : BrokerColors.red;

    final glowPaint = Paint()
      ..color = color.withOpacity(.22)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarSparklinePainter oldDelegate) {
    return oldDelegate.up != up;
  }
}
