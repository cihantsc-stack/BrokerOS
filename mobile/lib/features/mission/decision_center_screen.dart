import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../shared/widgets/broker_page.dart';
import 'widgets/ai_brief_card.dart';
import 'widgets/croc_header.dart';
import 'widgets/live_market_strip.dart';
import 'widgets/market_hero_card.dart';
import 'widgets/market_snapshot_grid.dart';
import 'widgets/opportunity_list_card.dart';
import 'widgets/risk_discipline_card.dart';
import 'widgets/smart_money_card.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();
    final strongest = stocks.first;
    final totalSmartMoney = stocks.fold<double>(
      0,
      (sum, item) => sum + (item.smartMoneyFlow ?? 0),
    );

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrocHeader(),
          const SizedBox(height: 18),
          LiveMarketStrip(totalSmartMoney: totalSmartMoney),
          const SizedBox(height: 16),
          MarketHeroCard(stock: strongest),
          const SizedBox(height: 16),
          AiBriefCard(stock: strongest),
          const SizedBox(height: 16),
          const MarketSnapshotGrid(),
          const SizedBox(height: 16),
          OpportunityListCard(stocks: stocks),
          const SizedBox(height: 16),
          SmartMoneyCard(
            totalSmartMoney: totalSmartMoney,
            leader: strongest,
          ),
          const SizedBox(height: 16),
          const RiskDisciplineCard(),
        ],
      ),
    );
  }
}
