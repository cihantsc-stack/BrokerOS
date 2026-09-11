import 'package:flutter/material.dart';

import '../../widgets/hidden_structure_card.dart';
import '../../widgets/institutional_flow_center_card.dart';
import '../../widgets/opportunity_comparator_card.dart';
import '../../widgets/smart_money_radar_card.dart';
import '../common/analysis_category.dart';

class MoneySection extends StatelessWidget {
  final String symbol;

  const MoneySection({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return AnalysisCategory(
      icon: Icons.account_balance_rounded,
      title: 'Para Akışı ve Kurumlar',
      subtitle: 'Smart Money, kurum hareketi ve gizli yapı.',
      children: [
        SmartMoneyRadarCard(symbol: symbol),
        InstitutionalFlowCenterCard(symbol: symbol),
        HiddenStructureCard(symbol: symbol),
        OpportunityComparatorCard(symbol: symbol),
      ],
    );
  }
}
