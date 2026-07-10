import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class LiveMarketStrip extends StatelessWidget {
  final double totalSmartMoney;

  const LiveMarketStrip({
    required this.totalSmartMoney,
  });

  String _money(double value) {
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} MLR';
    }
    return '+${(value / 1000000).toStringAsFixed(0)} MN';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      padding: const EdgeInsets.all(14),
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafiği değil, paranın izini sür.',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: MissionLiveMini(title: 'BIST100', value: '+1.82%'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: MissionLiveMini(title: 'USD/TL', value: '41.12'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MissionLiveMini(
                  title: 'SMART MONEY',
                  value: _money(totalSmartMoney),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, size: 9, color: BrokerColors.green),
              SizedBox(width: 8),
              Text(
                'CROC AI CANLI',
                style: TextStyle(
                  color: BrokerColors.textSoft,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
