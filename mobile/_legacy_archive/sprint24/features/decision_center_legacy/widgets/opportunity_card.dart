import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bugünün Fırsatları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          _AssetRow(code: 'ASELS', title: 'Savunma güçlü', score: 'AI %91'),
          _AssetRow(code: 'THYAO', title: 'Hacim artışı', score: 'AI %87'),
          _AssetRow(code: 'GARAN', title: 'Para girişi', score: 'AI %84'),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final String code;
  final String title;
  final String score;

  const _AssetRow({
    required this.code,
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Row(
        children: [
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: BrokerColors.textSoft))),
          Text(score, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
