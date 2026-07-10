import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class MarketHeroCard extends StatelessWidget {
  final StockAnalysis stock;

  const MarketHeroCard({
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionCardTitle(
            icon: Icons.psychology_alt_rounded,
            title: 'Bugünkü Piyasa Kararı',
          ),
          const SizedBox(height: 16),
          const Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 33,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          InteractiveGlossaryText(
            'Piyasa genelinde Smart Money pozitif. En güçlü aday ${stock.symbol}. Momentum güçlü ama Volatilite orta seviyede. Bu nedenle her hisse için ayrı Stop planı gerekli.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MissionMiniStat(
                  title: 'Güven',
                  value: '%${stock.confidence}',
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MissionMiniStat(
                  title: 'Risk',
                  value: stock.risk,
                  color: BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MissionMiniStat(
                  title: 'Skor',
                  value: '${stock.brokerConsensus}',
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
