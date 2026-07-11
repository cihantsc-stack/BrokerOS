import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class AiBriefCard extends StatelessWidget {
  final StockAnalysis stock;

  const AiBriefCard({
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionCardTitle(
            icon: Icons.smart_toy_rounded,
            title: 'CROC AI Sabah Yorumu',
          ),
          const SizedBox(height: 14),
          InteractiveGlossaryText(
            'Bugün tek işlem yapacak olsam güçlü kurumsal para izini takip ederim. ${stock.symbol} radarın en güçlü adayı. Smart Money pozitif, Momentum güçlü ve Stop disiplini korunursa senaryo destekleniyor.',
          ),
        ],
      ),
    );
  }
}
