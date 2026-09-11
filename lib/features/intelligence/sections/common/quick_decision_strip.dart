import 'package:flutter/material.dart';

import '../../../../shared/design/broker_colors.dart';

class QuickDecisionStrip extends StatelessWidget {
  final dynamic result;

  const QuickDecisionStrip({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickInfo(
          label: 'Karar',
          value: _simpleDecision(result.decision.toString()),
          tone: _decisionTone(result.decision.toString()),
        ),
        const SizedBox(width: 7),
        _QuickInfo(
          label: 'Güven',
          value: '%${result.confidence}',
          tone: BrokerColors.primary,
        ),
        const SizedBox(width: 7),
        _QuickInfo(
          label: 'Risk',
          value: result.risk.toString(),
          tone: _riskTone(result.risk.toString()),
        ),
      ],
    );
  }

  static String _simpleDecision(String decision) {
    if (decision.contains('GÜÇLÜ AL')) return 'Çok Güçlü';
    if (decision.contains('AL')) return 'Olumlu';
    if (decision.contains('İZLE')) return 'İzle';
    if (decision.contains('TEYİT')) return 'Bekle';
    return 'Riskli';
  }

  static Color _decisionTone(String decision) {
    if (decision.contains('AL')) return BrokerColors.green;
    if (decision.contains('İZLE') || decision.contains('TEYİT')) {
      return BrokerColors.orange;
    }
    return BrokerColors.red;
  }

  static Color _riskTone(String risk) {
    final normalized = risk.toUpperCase();
    if (normalized.contains('DÜŞÜK')) return BrokerColors.green;
    if (normalized.contains('ORTA')) return BrokerColors.orange;
    return BrokerColors.red;
  }
}

class _QuickInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _QuickInfo({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
