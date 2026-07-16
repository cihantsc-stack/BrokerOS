import 'package:flutter/material.dart';

import '../../../core/models/ai_timeline_step.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiTimelineCard extends StatelessWidget {
  final List<AiTimelineStep> timeline;

  const AiTimelineCard({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    if (timeline.isEmpty) {
      return const SizedBox.shrink();
    }

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 20),
          for (int index = 0; index < timeline.length; index++)
            _TimelineItem(
              step: timeline[index],
              isLast: index == timeline.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.20),
            ),
          ),
          child: const Icon(
            Icons.timeline_rounded,
            color: BrokerColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CROC AI Günlük Plan',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gün içinde hangi aşamada ne yapılacağını gösterir.',
                style: TextStyle(
                  color: BrokerColors.textSoft,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final AiTimelineStep step;
  final bool isLast;

  const _TimelineItem({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = step.isCritical
        ? BrokerColors.orange
        : BrokerColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              step.time,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: BrokerColors.borderSoft,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 22,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.isCritical
                      ? BrokerColors.orange.withValues(alpha: 0.07)
                      : BrokerColors.cardSoft,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: step.isCritical
                        ? BrokerColors.orange.withValues(alpha: 0.22)
                        : BrokerColors.borderSoft,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              color: BrokerColors.textMain,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (step.isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: BrokerColors.orange
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'KRİTİK',
                              style: TextStyle(
                                color: BrokerColors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      step.description,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}