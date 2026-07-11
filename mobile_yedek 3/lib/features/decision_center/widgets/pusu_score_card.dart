import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class PusuScoreCard extends StatelessWidget {
  const PusuScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.radar_rounded,
                color: BrokerColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                "PUSU SKORU™",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Center(
            child: Column(
              children: [
                Text(
                  "94",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: BrokerColors.primary,
                  ),
                ),
                Text(
                  "/100",
                  style: TextStyle(color: BrokerColors.textSoft),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _ScoreRow("Teknik Analiz", 95),
          const _ScoreRow("Para Akışı", 92),
          const _ScoreRow("Kurumsal", 96),
          const _ScoreRow("Haber Etkisi", 89),
          const _ScoreRow("Risk", 82),
          const _ScoreRow("Momentum", 94),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final int score;

  const _ScoreRow(this.title, this.score);

  @override
  Widget build(BuildContext context) {
    Color color;

    if (score >= 90) {
      color = BrokerColors.green;
    } else if (score >= 75) {
      color = BrokerColors.orange;
    } else {
      color = BrokerColors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "$score",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: BrokerColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}