import 'package:flutter/material.dart';

import '../../../core/repository/mock_market_repository.dart';
import '../../../core/services/decision_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiDecisionCard extends StatelessWidget {
  const AiDecisionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DecisionService(MockMarketRepository());
    final decision = service.getTodayDecision();

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Broker AI Kararı',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Text(
            decision.decision,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: BrokerColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            decision.explanation,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: 'PUSU',
                  value: '${decision.pusuScore}',
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  title: 'Güven',
                  value: '%${decision.confidence}',
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  title: 'Risk',
                  value: decision.risk,
                  color: BrokerColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}