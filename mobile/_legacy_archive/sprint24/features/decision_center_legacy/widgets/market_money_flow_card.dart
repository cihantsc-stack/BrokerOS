import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class MarketMoneyFlowCard extends StatelessWidget {
  const MarketMoneyFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Piyasa Para Akışı',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Borsaya giren ve çıkan para tek ekranda.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          SizedBox(height: 18),

          _BigFlowBox(
            title: 'BIST Günlük Hacim',
            value: '₺142.8B',
            subtitle: 'Düne göre +18%',
            color: BrokerColors.primary,
          ),

          SizedBox(height: 12),

          _BigFlowBox(
            title: 'Net Para Girişi',
            value: '+₺4.2B',
            subtitle: 'Piyasaya yeni para giriyor',
            color: BrokerColors.green,
          ),

          SizedBox(height: 18),

          Text(
            'En Güçlü Girişler',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _FlowRow(name: 'Bankacılık', value: '+₺1.8B', positive: true),
          _FlowRow(name: 'Savunma', value: '+₺740M', positive: true),

          SizedBox(height: 12),

          Text(
            'En Güçlü Çıkışlar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _FlowRow(name: 'Enerji', value: '-₺620M', positive: false),
          _FlowRow(name: 'Gıda', value: '-₺210M', positive: false),
        ],
      ),
    );
  }
}

class _BigFlowBox extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _BigFlowBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: BrokerColors.textSoft)),
        ],
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  final String name;
  final String value;
  final bool positive;

  const _FlowRow({
    required this.name,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? BrokerColors.green : BrokerColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}