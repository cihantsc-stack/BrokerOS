import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiPulseCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiPulseCard({super.key, required this.stock, required this.decision});

  @override
  Widget build(BuildContext context) {
    final pulse =
        ((decision.confidence * 0.55) +
                (stock.smartMoneyScore * 0.25) +
                (stock.momentumScore * 0.20))
            .round()
            .clamp(0, 100);

    final color = pulse >= 85
        ? BrokerColors.green
        : pulse >= 65
        ? BrokerColors.orange
        : BrokerColors.red;

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.monitor_heart_rounded,
                color: BrokerColors.primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Nabzı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pulse',
                style: TextStyle(
                  color: color,
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  '/100',
                  style: TextStyle(
                    color: BrokerColors.textSoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pulse / 100,
              minHeight: 13,
              backgroundColor: BrokerColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pulse >= 85
                ? 'AI sinyalleri güçlü ve birbiriyle uyumlu.'
                : pulse >= 65
                ? 'AI görünümü pozitif ancak teyit disiplini korunmalı.'
                : 'Sinyaller dağınık. Yeni işlem için bekleme modu daha sağlıklı.',
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
