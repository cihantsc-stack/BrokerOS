import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class SmartMoneyCard extends StatelessWidget {
  final double totalSmartMoney;
  final StockAnalysis leader;

  const SmartMoneyCard({
    required this.totalSmartMoney,
    required this.leader,
  });

  String _money(double value) {
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} Milyar TL';
    }
    return '+${(value / 1000000).toStringAsFixed(0)} Milyon TL';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MissionCardTitle(
            icon: Icons.account_balance_rounded,
            title: 'Kurumsal Para Akışı',
          ),
          const SizedBox(height: 14),
          Text(
            _money(totalSmartMoney),
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          InteractiveGlossaryText(
            'Son 60 dakikada Smart Money tarafı pozitif. ${leader.firstInstitution ?? 'İş Yatırım'}, ${leader.secondInstitution ?? 'Ak Yatırım'} ve ${leader.thirdInstitution ?? 'Yapı Kredi'} net alıcı tarafta.',
          ),
        ],
      ),
    );
  }
}
