import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../features/intelligence/broker_intelligence_screen.dart';
import '../../shared/widgets/broker_page.dart';
import 'widgets/radar_header.dart';
import 'widgets/radar_stock_card.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RadarHeader(),
          const SizedBox(height: 18),
          ...stocks.map(
            (stock) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RadarStockCard(
                stock: stock,
                onOpenReport: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BrokerIntelligenceScreen(symbol: stock.symbol),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
