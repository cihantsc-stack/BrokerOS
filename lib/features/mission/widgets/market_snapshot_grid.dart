import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class MarketSnapshotGrid extends StatelessWidget {
  const MarketSnapshotGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _MarketItem(label: 'BIST 100', value: '+1.82%', tone: BrokerColors.green),
      _MarketItem(label: 'BIST 30', value: '+1.46%', tone: BrokerColors.green),
      _MarketItem(label: 'VİOP 30', value: '+1.24%', tone: BrokerColors.green),
      _MarketItem(
        label: 'DOLAR/TL',
        value: '41.12',
        tone: BrokerColors.textMain,
      ),
      _MarketItem(
        label: 'EURO/TL',
        value: '47.86',
        tone: BrokerColors.textMain,
      ),
      _MarketItem(
        label: 'GRAM ALTIN',
        value: '4.392 ₺',
        tone: BrokerColors.orange,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.82)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _PanoramaIcon(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Piyasa Panoraması',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 3 : 2;
              const spacing = 10.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items
                    .map((item) => SizedBox(width: width, child: item))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PanoramaIcon extends StatelessWidget {
  const _PanoramaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.25)),
      ),
      child: const Icon(
        Icons.monitor_heart_rounded,
        color: BrokerColors.primary,
      ),
    );
  }
}

class _MarketItem extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _MarketItem({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: tone,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
