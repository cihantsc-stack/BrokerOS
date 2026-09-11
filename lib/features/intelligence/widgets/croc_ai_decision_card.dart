import 'package:flutter/material.dart';

import '../../../core/decision/models/croc_decision_result.dart';
import '../../../core/decision/models/decision_vote.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class CrocAiDecisionCard extends StatelessWidget {
  final CrocDecisionResult result;

  const CrocAiDecisionCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Color decisionColor = _decisionColor(result.decision);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: BrokerColors.primary,
                size: 31,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PRO PACK 1E • CROC AI Kararı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: decisionColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: decisionColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  result.symbol,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  result.decision,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: decisionColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.positiveVoteCount}/${result.totalVoteCount} '
                  'modül olumlu oy verdi',
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  title: 'AI Skoru',
                  value: '${result.score}/100',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'Güven',
                  value: '%${result.confidence}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'Olasılık',
                  value: '%${result.successProbability}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricBox(title: 'Risk', value: result.risk),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(title: 'Süre', value: result.tradeWindow),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricBox(
                  title: 'Risk/Ödül',
                  value: '1:${result.riskReward.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          const Text(
            'Modül Oylaması',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...result.votes.map((DecisionVote vote) => _VoteRow(vote: vote)),
          const SizedBox(height: 15),
          const Text(
            'CROC AI Açıklaması',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            result.narrative,
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 14),
          _PlanRow(
            title: 'Giriş',
            value: '${result.entry.toStringAsFixed(2)} ₺',
          ),
          _PlanRow(
            title: 'Hedef',
            value: '${result.target.toStringAsFixed(2)} ₺',
          ),
          _PlanRow(title: 'Stop', value: '${result.stop.toStringAsFixed(2)} ₺'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrokerColors.red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BrokerColors.red.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              'Fikrim ne zaman değişir? ${result.invalidation}',
              style: const TextStyle(
                color: BrokerColors.textMain,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Bu kart geliştirme/demo verilerini karar motorunda '
            'birleştirir. Yatırım tavsiyesi değildir.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Color _decisionColor(String decision) {
    if (decision.contains('AL')) {
      return BrokerColors.green;
    }

    if (decision.contains('UZAK')) {
      return BrokerColors.red;
    }

    return BrokerColors.primary;
  }
}

class _VoteRow extends StatelessWidget {
  final DecisionVote vote;

  const _VoteRow({required this.vote});

  @override
  Widget build(BuildContext context) {
    final Color color = vote.isPositive
        ? BrokerColors.green
        : vote.vote == DecisionVoteType.sell
        ? BrokerColors.red
        : BrokerColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vote.module,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vote.reason,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withValues(alpha: 0.20)),
            ),
            child: Text(
              '${vote.label} • ${vote.score}',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const _MetricBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String title;
  final String value;

  const _PlanRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
