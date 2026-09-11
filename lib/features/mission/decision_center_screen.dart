import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../shared/widgets/broker_page.dart';
import 'widgets/ai_decision_center_card.dart';
import 'widgets/croc_header.dart';
import 'widgets/home_stock_search.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();
    final totalSmartMoney = stocks.fold<double>(
      0,
      (sum, item) => sum + (item.smartMoneyFlow ?? 0),
    );

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrocHeader(),
          const SizedBox(height: 12),
          HomeStockSearch(stocks: stocks),
          const SizedBox(height: 14),
          AiDecisionCenterCard(
            stocks: stocks,
            totalSmartMoney: totalSmartMoney,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
