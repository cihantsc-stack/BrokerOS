import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class OpportunityListCard extends StatelessWidget {
  final List<StockAnalysis> stocks;

  const OpportunityListCard({required this.stocks});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionCardTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Bugünün Fırsatları',
          ),
          const SizedBox(height: 14),
          ...stocks
              .take(3)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) => MissionOpportunityRow(
                  rank: '${entry.key + 1}',
                  stock: entry.value,
                ),
              ),
        ],
      ),
    );
  }
}
