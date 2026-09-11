import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';

class MissionCardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const MissionCardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrokerColors.primary.withOpacity(.18)),
          ),
          child: Icon(icon, color: BrokerColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class MissionLiveMini extends StatelessWidget {
  final String title;
  final String value;

  const MissionLiveMini({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionMiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const MissionMiniStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionMarketBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const MissionMarketBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionOpportunityRow extends StatelessWidget {
  final String rank;
  final StockAnalysis stock;

  const MissionOpportunityRow({required this.rank, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            stock.symbol,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stock.decision,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${stock.brokerConsensus}',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionWarningLine extends StatelessWidget {
  final String text;

  const MissionWarningLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: BrokerColors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
        ],
      ),
    );
  }
}
