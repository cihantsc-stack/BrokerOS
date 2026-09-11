import 'package:flutter/material.dart';

import '../../../../core/models/stock_analysis.dart';
import '../../../../shared/design/broker_colors.dart';
import '../../../../shared/widgets/broker_card.dart';
import '../../widgets/plain_language_explainer_card.dart';
import '../../widgets/simple_position_calculator_card.dart';
import '../../widgets/simple_risk_card.dart';
import '../../widgets/simple_scenario_card.dart';
import '../../widgets/trade_readiness_card.dart';

class PlanningToolsSection extends StatelessWidget {
  final StockAnalysis stock;
  final dynamic crocDecision;

  const PlanningToolsSection({
    super.key,
    required this.stock,
    required this.crocDecision,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 12),
          iconColor: BrokerColors.primary,
          collapsedIconColor: BrokerColors.primary,
          title: const Text(
            'Planlama Araçları',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: const Text(
            'Risk, adet hesabı ve senaryoları yalnızca ihtiyaç duyduğunda aç.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          children: [
            _CompactToolExpansion(
              icon: Icons.record_voice_over_rounded,
              title: 'Kararı Bana Anlat',
              subtitle: 'Tek cümle, basit veya detaylı anlatım.',
              child: PlainLanguageExplainerCard(result: crocDecision),
            ),
            const SizedBox(height: 8),
            _CompactToolExpansion(
              icon: Icons.shield_outlined,
              title: 'Risk Durumu',
              subtitle: 'İşlemin dikkat edilmesi gereken tarafı.',
              child: SimpleRiskCard(stock: stock),
            ),
            const SizedBox(height: 8),
            _CompactToolExpansion(
              icon: Icons.calculate_outlined,
              title: 'Ne Kadar Almalıyım?',
              subtitle: 'Portföye göre yaklaşık lot hesabı.',
              child: SimplePositionCalculatorCard(stock: stock),
            ),
            const SizedBox(height: 8),
            _CompactToolExpansion(
              icon: Icons.fact_check_outlined,
              title: 'İşleme Hazır mıyım?',
              subtitle: 'Alım öncesi dört maddelik kontrol.',
              child: TradeReadinessCard(stock: stock),
            ),
            const SizedBox(height: 8),
            _CompactToolExpansion(
              icon: Icons.alt_route_rounded,
              title: 'Üç Olası Senaryo',
              subtitle: 'Yükseliş, yatay hareket ve düşüş planı.',
              child: SimpleScenarioCard(stock: stock),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactToolExpansion extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _CompactToolExpansion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.10)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: BrokerColors.primary),
          title: Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 11),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
          children: [child],
        ),
      ),
    );
  }
}
