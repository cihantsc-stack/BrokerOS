import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SectorHeatmapCard extends StatelessWidget {
  const SectorHeatmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sektör Isı Haritası',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'Paranın en çok aktığı ve zayıflayan sektörler.',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          SizedBox(height: 18),
          _SectorBar(name: 'Savunma', value: 0.92, label: 'Çok Güçlü', color: BrokerColors.green),
          _SectorBar(name: 'Bankacılık', value: 0.78, label: 'Güçlü', color: BrokerColors.green),
          _SectorBar(name: 'Teknoloji', value: 0.58, label: 'İzleniyor', color: BrokerColors.orange),
          _SectorBar(name: 'Enerji', value: 0.32, label: 'Zayıf', color: BrokerColors.red),
          _SectorBar(name: 'Gıda', value: 0.24, label: 'Zayıf', color: BrokerColors.red),
        ],
      ),
    );
  }
}

class _SectorBar extends StatelessWidget {
  final String name;
  final double value;
  final String label;
  final Color color;

  const _SectorBar({
    required this.name,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: BrokerColors.border,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}