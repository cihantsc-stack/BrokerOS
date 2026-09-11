import 'package:flutter/material.dart';

import '../../../core/explainability/explainability_item.dart';
import '../../../shared/design/broker_colors.dart';
import 'score_delta_chip.dart';

class FactorBar extends StatelessWidget {
  final ExplainabilityItem item;

  const FactorBar({super.key, required this.item});

  Color get _color {
    if (item.score >= 82) return BrokerColors.green;
    if (item.score >= 60) return BrokerColors.orange;
    return BrokerColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.factor,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ScoreDeltaChip(delta: item.change.delta),
            const SizedBox(width: 8),
            Text(
              '${item.score}',
              style: TextStyle(
                color: _color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: item.score / 100,
            minHeight: 10,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${item.explanation} Karar katkısı: ${item.contribution} puan.',
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
