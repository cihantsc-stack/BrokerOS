import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class ConsensusCard extends StatelessWidget {
  const ConsensusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.hub_rounded,
                  color: BrokerColors.primary, size: 26),
              SizedBox(width: 10),
              Text(
                "Broker Konsensüsü",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Yapay zekâ; teknik analiz, para akışı ve haberleri birlikte değerlendiriyor.",
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          SizedBox(height: 24),

          _ConsensusBar(
            title: "Olumlu",
            value: 17,
            max: 20,
            color: BrokerColors.green,
          ),

          SizedBox(height: 18),

          _ConsensusBar(
            title: "Bekle",
            value: 12,
            max: 20,
            color: BrokerColors.orange,
          ),

          SizedBox(height: 18),

          _ConsensusBar(
            title: "Riskli",
            value: 4,
            max: 20,
            color: BrokerColors.red,
          ),
        ],
      ),
    );
  }
}

class _ConsensusBar extends StatelessWidget {
  final String title;
  final int value;
  final int max;
  final Color color;

  const _ConsensusBar({
    required this.title,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = value / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "$value",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: BrokerColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}