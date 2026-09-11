import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class LiveMarketStrip extends StatelessWidget {
  final double totalSmartMoney;

  const LiveMarketStrip({super.key, required this.totalSmartMoney});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafiği değil, paranın izini sür.',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 620;

              final cards = [
                const _LiveMetric(
                  label: 'BIST 100',
                  value: '+1.82%',
                  tone: BrokerColors.green,
                ),
                const _LiveMetric(
                  label: 'BIST 30',
                  value: '+1.46%',
                  tone: BrokerColors.green,
                ),
                _LiveMetric(
                  label: 'PARA AKIŞI',
                  value:
                      '${totalSmartMoney >= 0 ? '+' : ''}'
                      '${totalSmartMoney.toStringAsFixed(2)} MLR',
                  tone: totalSmartMoney >= 0
                      ? BrokerColors.green
                      : BrokerColors.red,
                ),
              ];

              if (narrow) {
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      cards[i],
                      if (i != cards.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.circle, color: BrokerColors.green, size: 10),
              SizedBox(width: 9),
              Text(
                'CROC AI CANLI • PİYASA GENELİ İZLENİYOR',
                style: TextStyle(
                  color: BrokerColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _LiveMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
