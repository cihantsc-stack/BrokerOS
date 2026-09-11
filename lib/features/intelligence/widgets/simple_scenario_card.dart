import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SimpleScenarioCard extends StatelessWidget {
  final StockAnalysis stock;

  const SimpleScenarioCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3 OLASI SENARYO',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Fiyat hangi yöne giderse ne yapacağını önceden bil.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          _ScenarioTile(
            icon: Icons.trending_up_rounded,
            tone: BrokerColors.green,
            title: 'Fiyat yükselirse',
            headline:
                '${stock.target1.toStringAsFixed(2)} ₺ ilk hedefini takip et.',
            explanation:
                'Hedefe yaklaşınca kârın bir kısmını korumak düşünülebilir. '
                'Fiyat çok hızlı yükselirse peşinden koşma.',
          ),
          const SizedBox(height: 10),
          _ScenarioTile(
            icon: Icons.horizontal_rule_rounded,
            tone: BrokerColors.primary,
            title: 'Fiyat yatay kalırsa',
            headline:
                '${stock.entry.toStringAsFixed(2)} ₺ çevresindeki hareketi izle.',
            explanation:
                'Acele karar verme. İşlem hacmi ve alıcı gücü artmadan pozisyonu büyütme.',
          ),
          const SizedBox(height: 10),
          _ScenarioTile(
            icon: Icons.trending_down_rounded,
            tone: BrokerColors.red,
            title: 'Fiyat düşerse',
            headline:
                '${stock.stop.toStringAsFixed(2)} ₺ zarar sınırını unutma.',
            explanation:
                'Stop seviyesinin altında plan bozulur. Zararı büyütmek yerine riski azalt.',
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology_alt_rounded,
                  color: BrokerColors.primary,
                  size: 21,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Amaç geleceği kesin bilmek değil; her ihtimal için önceden hazırlanmak.',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ScenarioTile extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String headline;
  final String explanation;

  const _ScenarioTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.headline,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: tone.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tone, size: 22),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tone,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headline,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  explanation,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.4,
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
