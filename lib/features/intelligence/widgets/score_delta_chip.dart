import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class ScoreDeltaChip extends StatelessWidget {
  final int delta;

  const ScoreDeltaChip({super.key, required this.delta});

  @override
  Widget build(BuildContext context) {
    final color = delta > 0
        ? BrokerColors.green
        : delta < 0
        ? BrokerColors.red
        : BrokerColors.orange;

    final text = delta > 0 ? '+$delta' : '$delta';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
