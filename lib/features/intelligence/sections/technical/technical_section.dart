import 'package:flutter/material.dart';

import '../../../../core/models/stock_analysis.dart';
import '../../../../shared/design/broker_colors.dart';
import '../../../../shared/widgets/broker_card.dart';
import '../common/analysis_category.dart';

class TechnicalSection extends StatelessWidget {
  final StockAnalysis stock;

  const TechnicalSection({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final change = stock.dailyChange ?? 0;
    final positive = change >= 0;

    return AnalysisCategory(
      icon: Icons.candlestick_chart_rounded,
      title: 'Teknik Görünüm',
      subtitle: 'Momentum, günlük yön ve Broker Consensus özeti.',
      children: [
        BrokerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teknik Karar Özeti',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _TechnicalRow(
                label: 'Günlük yön',
                value: '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
                tone: positive ? BrokerColors.green : BrokerColors.red,
              ),
              const SizedBox(height: 10),
              _TechnicalRow(
                label: 'Broker Consensus',
                value: '${stock.brokerConsensus}/100',
                tone: BrokerColors.primary,
              ),
              const SizedBox(height: 10),
              _TechnicalRow(
                label: 'Nihai teknik eğilim',
                value: stock.decision,
                tone: stock.decision.contains('AL')
                    ? BrokerColors.green
                    : BrokerColors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechnicalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _TechnicalRow({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: tone, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
