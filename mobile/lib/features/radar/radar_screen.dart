import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📡 Broker Radar',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'AI bugün filtreyi geçen en güçlü fırsatları taradı.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 20),
          ...stocks.map(
            (stock) => BrokerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: BrokerColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(stock.company, style: const TextStyle(color: BrokerColors.textSoft)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _Mini(title: 'AI', value: '${stock.aiScore}')),
                      const SizedBox(width: 10),
                      Expanded(child: _Mini(title: 'Karar', value: stock.decision)),
                      const SizedBox(width: 10),
                      Expanded(child: _Mini(title: 'Risk', value: stock.risk)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Neden: ${stock.reasons.join(", ")}',
                    style: const TextStyle(color: BrokerColors.textSoft, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String title;
  final String value;

  const _Mini({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}