import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SimpleTradePlanCard extends StatelessWidget {
  final StockAnalysis stock;

  const SimpleTradePlanCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final double riskAmount = stock.entry - stock.stop;
    final double rewardAmount = stock.target1 - stock.entry;
    final double riskPercent = stock.entry == 0
        ? 0
        : (riskAmount / stock.entry) * 100;
    final double rewardPercent = stock.entry == 0
        ? 0
        : (rewardAmount / stock.entry) * 100;

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İŞLEM PLANI',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Almadan önce giriş, kazanç hedefi ve zarar sınırını bil.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 15),
          _PlanStep(
            number: '1',
            title: 'Giriş',
            explanation: 'Bu fiyat civarında işlem düşünülebilir.',
            value: '${stock.entry.toStringAsFixed(2)} ₺',
            tone: BrokerColors.primary,
          ),
          const SizedBox(height: 9),
          _PlanStep(
            number: '2',
            title: 'İlk hedef',
            explanation: 'Fiyat buraya gelirse kâr almak düşünülebilir.',
            value: '${stock.target1.toStringAsFixed(2)} ₺',
            tone: BrokerColors.green,
          ),
          const SizedBox(height: 9),
          _PlanStep(
            number: '3',
            title: 'Zarar sınırı',
            explanation: 'Fiyat bunun altına inerse plan bozulur.',
            value: '${stock.stop.toStringAsFixed(2)} ₺',
            tone: BrokerColors.red,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              'Basit hesap: Yaklaşık %${rewardPercent.abs().toStringAsFixed(1)} '
              'kazanç hedefi için %${riskPercent.abs().toStringAsFixed(1)} '
              'zarar riski alınıyor.',
              style: const TextStyle(
                color: BrokerColors.textMain,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'İkinci hedef: ${stock.target2.toStringAsFixed(2)} ₺',
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PlanStep extends StatelessWidget {
  final String number;
  final String title;
  final String explanation;
  final String value;
  final Color tone;

  const _PlanStep({
    required this.number,
    required this.title,
    required this.explanation,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(color: tone, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  explanation,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
