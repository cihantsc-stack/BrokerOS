import 'package:flutter/material.dart';

import '../../../core/ai/council/council_result.dart';
import '../../../core/ai/council/council_vote.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class BrokerCouncilCard extends StatelessWidget {
  final CouncilResult result;

  const BrokerCouncilCard({super.key, required this.result});

  Color get _decisionColor {
    if (result.finalDecision.contains('AL')) return BrokerColors.green;
    if (result.finalDecision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const SizedBox(height: 18),
          _FinalDecision(
            decision: result.finalDecision,
            confidence: result.confidence,
            strongestEngine: result.strongestEngine,
            color: _decisionColor,
          ),
          const SizedBox(height: 18),
          _VoteSummary(result: result),
          const SizedBox(height: 18),
          for (final vote in result.votes) ...[
            _VoteRow(vote: vote),
            if (vote != result.votes.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          _ConflictBox(summary: result.conflictSummary),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.groups_2_rounded, color: BrokerColors.primary, size: 30),
        SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broker Council',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Altı bağımsız AI motorunun ortak kararı.',
                style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinalDecision extends StatelessWidget {
  final String decision;
  final int confidence;
  final String strongestEngine;
  final Color color;

  const _FinalDecision({
    required this.decision,
    required this.confidence,
    required this.strongestEngine,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NİHAİ KONSEY KARARI',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  decision,
                  style: TextStyle(
                    color: color,
                    fontSize: 31,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%$confidence',
                style: const TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 11,
              backgroundColor: BrokerColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'En güçlü motor: $strongestEngine',
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteSummary extends StatelessWidget {
  final CouncilResult result;

  const _VoteSummary({required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: 'AL',
            value: result.buyVotes,
            color: BrokerColors.green,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _SummaryBox(
            title: 'BEKLE',
            value: result.waitVotes,
            color: BrokerColors.orange,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _SummaryBox(
            title: 'SAT',
            value: result.sellVotes,
            color: BrokerColors.red,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  final CouncilVote vote;

  const _VoteRow({required this.vote});

  Color get _color {
    if (vote.decision.contains('AL')) return BrokerColors.green;
    if (vote.decision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  IconData get _icon {
    switch (vote.engine) {
      case 'Teknik AI':
        return Icons.show_chart_rounded;
      case 'Smart Money AI':
        return Icons.account_balance_rounded;
      case 'Haber AI':
        return Icons.newspaper_rounded;
      case 'Risk AI':
        return Icons.shield_rounded;
      case 'Momentum AI':
        return Icons.speed_rounded;
      default:
        return Icons.psychology_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vote.engine,
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${vote.decision} • ${vote.score}',
                      style: TextStyle(
                        color: _color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vote.reason,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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

class _ConflictBox extends StatelessWidget {
  final String summary;

  const _ConflictBox({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.orange.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.compare_arrows_rounded,
            color: BrokerColors.orange,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Çelişki Analizi',
                  style: TextStyle(
                    color: BrokerColors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  summary,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
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
