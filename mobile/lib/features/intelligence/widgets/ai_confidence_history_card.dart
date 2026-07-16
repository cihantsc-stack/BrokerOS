import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiConfidenceHistoryCard extends StatelessWidget {
  final AiDecision decision;

  const AiConfidenceHistoryCard({
    super.key,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final morning = (decision.confidence - 2).clamp(0, 100);
    final noon = decision.confidence;
    final close = (decision.confidence - 5).clamp(0, 100);

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: BrokerColors.primary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Güven Geçmişi',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ConfidenceRow(label: 'Sabah', value: morning),
          const SizedBox(height: 12),
          _ConfidenceRow(label: 'Öğlen', value: noon),
          const SizedBox(height: 12),
          _ConfidenceRow(label: 'Kapanış Senaryosu', value: close),
        ],
      ),
    );
  }
}

class _ConfidenceRow extends StatelessWidget {
  final String label;
  final int value;

  const _ConfidenceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 85
        ? BrokerColors.green
        : value >= 65
            ? BrokerColors.orange
            : BrokerColors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '%$value',
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 9,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
