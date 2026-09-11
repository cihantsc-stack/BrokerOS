import 'package:flutter/material.dart';

import '../../../core/consensus/consensus_vote.dart';
import '../../../core/timeline/decision_change.dart';
import '../../../core/timeline/decision_snapshot.dart';
import '../../../shared/design/broker_colors.dart';

class DecisionReasonDialog extends StatelessWidget {
  final DecisionSnapshot snapshot;
  final List<DecisionChange> changes;

  const DecisionReasonDialog({
    super.key,
    required this.snapshot,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        '${snapshot.symbol} • ${snapshot.signal.label}',
        style: const TextStyle(
          color: BrokerColors.textMain,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Karar neden değişti?',
                style: TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              for (final change in changes) ...[
                _ChangeRow(change: change),
                const SizedBox(height: 9),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Kapat',
            style: TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final DecisionChange change;

  const _ChangeRow({required this.change});

  @override
  Widget build(BuildContext context) {
    final Color tone = change.positive
        ? BrokerColors.primary
        : BrokerColors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(
            change.positive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: tone,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              change.label,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${change.previousValue} → ${change.currentValue}',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
