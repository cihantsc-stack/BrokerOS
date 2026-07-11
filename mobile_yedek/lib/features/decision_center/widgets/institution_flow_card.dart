import 'package:flutter/material.dart';

import '../../../core/services/institution_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class InstitutionFlowCard extends StatelessWidget {
  const InstitutionFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    final flows = InstitutionService.today();

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kurumsal Para Akışı',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bugün en agresif kurum hareketleri.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 16),
          ...flows.map(
            (item) => _InstitutionRow(
              name: item.institution,
              amount: item.amount,
              buy: item.buy,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final String name;
  final double amount;
  final bool buy;

  const _InstitutionRow({
    required this.name,
    required this.amount,
    required this.buy,
  });

  @override
  Widget build(BuildContext context) {
    final color = buy ? BrokerColors.green : BrokerColors.red;
    final sign = buy ? '+' : '-';

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
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$sign₺${amount.toStringAsFixed(1)}M',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}