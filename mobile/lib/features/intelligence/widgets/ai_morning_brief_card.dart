import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiMorningBriefCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiMorningBriefCard({
    super.key,
    required this.stock,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: BrokerColors.primary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CROC AI Sabah Brifingi',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${stock.symbol} bugün ${decision.decision.toLowerCase()} görünümünde. '
            'İlk 15 dakika fiyat ve hacim teyidi beklenmeli. '
            '${stock.stop.toStringAsFixed(2)} stop, '
            '${stock.target1.toStringAsFixed(2)} ilk hedef, '
            '${stock.target2.toStringAsFixed(2)} ikinci hedef olarak izleniyor.',
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
