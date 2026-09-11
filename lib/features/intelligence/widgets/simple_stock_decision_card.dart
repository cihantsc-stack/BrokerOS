import 'package:flutter/material.dart';

import '../../../core/decision/models/croc_decision_result.dart';
import '../../../core/learning/presentation/beginner_decision_language.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SimpleStockDecisionCard extends StatelessWidget {
  final CrocDecisionResult result;

  const SimpleStockDecisionCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Color tone = _toneFor(result.decision);
    final String simpleTitle = BeginnerDecisionLanguage.simpleTitle(
      result.decision,
    );
    final String stars = BeginnerDecisionLanguage.stars(result.score);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BUGÜN NE YAPMALIYIM?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'CROC AI bütün verileri senin için özetledi.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: tone.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  simpleTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tone,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  stars,
                  style: TextStyle(
                    color: tone,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  BeginnerDecisionLanguage.plainExplanation(result),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PlainMetric(
                  title: 'AI güveni',
                  value: BeginnerDecisionLanguage.confidenceText(
                    result.confidence,
                  ),
                  detail: '%${result.confidence}',
                  tone: tone,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _PlainMetric(
                  title: 'Risk',
                  value: BeginnerDecisionLanguage.riskText(result.risk),
                  detail: result.risk,
                  tone: _riskTone(result.risk),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _PlainMetric(
                  title: 'Süre',
                  value: result.tradeWindow,
                  detail: 'Tahmini',
                  tone: BrokerColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'NEDEN?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ...result.reasons
              .take(3)
              .map(
                (String reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: BrokerColors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            color: BrokerColors.textSoft,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: tone.withValues(alpha: 0.18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.touch_app_rounded, color: tone, size: 21),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    BeginnerDecisionLanguage.todayAction(result),
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Teknik puan: ${result.score}/100 • '
            '${result.positiveVoteCount}/${result.totalVoteCount} modül olumlu',
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 10),
          ),
          const SizedBox(height: 4),
          const Text(
            'Yatırım tavsiyesi değildir.',
            style: TextStyle(color: BrokerColors.textSoft, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _toneFor(String decision) {
    if (decision.contains('AL')) {
      return BrokerColors.green;
    }
    if (decision.contains('UZAK')) {
      return BrokerColors.red;
    }
    return BrokerColors.primary;
  }

  Color _riskTone(String risk) {
    final String value = risk.toUpperCase();

    if (value.contains('YÜKSEK')) {
      return BrokerColors.red;
    }
    if (value.contains('DÜŞÜK')) {
      return BrokerColors.green;
    }
    return BrokerColors.primary;
  }
}

class _PlainMetric extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final Color tone;

  const _PlainMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
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
            style: TextStyle(
              color: tone,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
