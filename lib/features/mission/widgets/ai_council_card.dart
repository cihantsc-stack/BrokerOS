import 'package:flutter/material.dart';

import '../../../core/services/broker_consensus_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiCouncilCard extends StatelessWidget {
  const AiCouncilCard({super.key});

  @override
  Widget build(BuildContext context) {
    final votes = BrokerConsensusService.getVotes();
    final score = BrokerConsensusService.consensusScore();
    final decision = BrokerConsensusService.finalDecision();

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Broker AI Council',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            '5 farklı AI motoru piyasayı birlikte değerlendirdi.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 18),
          Text(
            decision,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Consensus Skoru: $score / 100',
            style: const TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 18),
          ...votes.map(
            (vote) => _VoteRow(
              engine: vote.engine,
              decision: vote.decision,
              score: vote.score,
              reason: vote.reason,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  final String engine;
  final String decision;
  final int score;
  final String reason;

  const _VoteRow({
    required this.engine,
    required this.decision,
    required this.score,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 90
        ? BrokerColors.green
        : score >= 70
        ? BrokerColors.orange
        : BrokerColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  engine,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                decision,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(reason, style: const TextStyle(color: BrokerColors.textSoft)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: BrokerColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
