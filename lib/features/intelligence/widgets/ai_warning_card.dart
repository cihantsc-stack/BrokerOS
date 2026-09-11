import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiWarningCard extends StatelessWidget {
  final AiDecision decision;

  const AiWarningCard({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    if (decision.warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.do_not_disturb_alt_rounded,
                color: BrokerColors.orange,
                size: 27,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün Bunları Yapma',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Karar kalitesini düşürecek davranışlar.',
                      style: TextStyle(color: BrokerColors.textSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final warning in decision.warnings)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: BrokerColors.orange.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BrokerColors.orange.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.close_rounded,
                    color: BrokerColors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      warning,
                      style: const TextStyle(
                        color: BrokerColors.textMain,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
