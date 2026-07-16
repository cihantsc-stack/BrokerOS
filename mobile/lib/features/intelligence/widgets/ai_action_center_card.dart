import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiActionCenterCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiActionCenterCard({
    super.key,
    required this.stock,
    required this.decision,
  });

  Color get _actionColor {
    if (decision.decision.contains('AL')) return BrokerColors.green;
    if (decision.decision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  String get _actionTitle {
    if (decision.decision.contains('GÜÇLÜ AL')) return 'Kademeli girişe hazırlan';
    if (decision.decision.contains('AL')) return 'Teyit gelirse işlem planını uygula';
    if (decision.decision.contains('SAT')) return 'Riski azalt';
    return 'Yeni teyit oluşana kadar bekle';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.gps_fixed_rounded,
                color: BrokerColors.primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Aksiyon Merkezi',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _actionColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _actionColor.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _actionTitle,
                  style: TextStyle(
                    color: _actionColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'İlk 15 dakika fiyat ve hacim teyidi bekle. '
                  '${stock.stop.toStringAsFixed(2)} stop seviyesini bozma.',
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    height: 1.5,
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
                child: _LevelBox(
                  title: 'STOP',
                  value: stock.stop.toStringAsFixed(2),
                  color: BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LevelBox(
                  title: 'HEDEF 1',
                  value: stock.target1.toStringAsFixed(2),
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LevelBox(
                  title: 'HEDEF 2',
                  value: stock.target2.toStringAsFixed(2),
                  color: BrokerColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _LevelBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
