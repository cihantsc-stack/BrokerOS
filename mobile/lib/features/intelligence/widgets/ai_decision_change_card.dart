import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiDecisionChangeCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiDecisionChangeCard({
    super.key,
    required this.stock,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.change_circle_rounded, color: BrokerColors.orange, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kararım Ne Zaman Değişir?',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Rule(
            title: 'Karar aşağı iner',
            description:
                '${stock.stop.toStringAsFixed(2)} altında günlük kapanış veya Smart Money skorunun 60 altına düşmesi.',
            color: BrokerColors.orange,
          ),
          const SizedBox(height: 10),
          _Rule(
            title: 'Karar güçlenir',
            description:
                '${stock.target1.toStringAsFixed(2)} üzerinde hacimli kapanış ve momentumun korunması.',
            color: BrokerColors.green,
          ),
          const SizedBox(height: 12),
          Text(
            'Mevcut güven: %${decision.confidence}',
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _Rule({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
