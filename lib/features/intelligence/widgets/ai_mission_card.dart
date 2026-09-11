import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiMissionCard extends StatelessWidget {
  final AiDecision decision;

  const AiMissionCard({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    if (decision.missions.isEmpty) {
      return const SizedBox.shrink();
    }

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: BrokerColors.primary, size: 27),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugünün Görevleri',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'CROC AI tarafından oluşturulan uygulanabilir plan.',
                      style: TextStyle(color: BrokerColors.textSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final mission in decision.missions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: BrokerColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      mission,
                      style: const TextStyle(
                        color: BrokerColors.textMain,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrokerColors.cardSoft,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: BrokerColors.borderSoft),
            ),
            child: Text(
              'Sonraki tetikleyici: ${decision.nextTrigger}',
              style: const TextStyle(
                color: BrokerColors.textMain,
                height: 1.45,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
