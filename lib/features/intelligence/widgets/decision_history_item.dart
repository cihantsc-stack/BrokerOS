import 'package:flutter/material.dart';

import '../../../core/consensus/consensus_vote.dart';
import '../../../core/timeline/decision_snapshot.dart';
import '../../../shared/design/broker_colors.dart';

class DecisionHistoryItem extends StatelessWidget {
  final DecisionSnapshot snapshot;
  final VoidCallback onTap;
  final bool isLatest;

  const DecisionHistoryItem({
    super.key,
    required this.snapshot,
    required this.onTap,
    required this.isLatest,
  });

  @override
  Widget build(BuildContext context) {
    final time =
        '${snapshot.createdAt.hour.toString().padLeft(2, '0')}:'
        '${snapshot.createdAt.minute.toString().padLeft(2, '0')}:'
        '${snapshot.createdAt.second.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLatest
                ? BrokerColors.primary.withValues(alpha: 0.07)
                : BrokerColors.textMain.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isLatest
                  ? BrokerColors.primary.withValues(alpha: 0.20)
                  : BrokerColors.textSoft.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                child: Text(
                  time,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  snapshot.signal.label,
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%${snapshot.confidence}',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: BrokerColors.textSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
