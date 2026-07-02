import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_page.dart';

import 'widgets/ai_decision_card.dart';
import 'widgets/ai_score_card.dart';
import 'widgets/consensus_card.dart';
import 'widgets/disclaimer_text.dart';
import 'widgets/institution_flow_card.dart';
import 'widgets/market_money_flow_card.dart';
import 'widgets/morning_brief_card.dart';
import 'widgets/news_impact_card.dart';
import 'widgets/opportunity_card.dart';
import 'widgets/pusu_score_card.dart';
import 'widgets/sector_heatmap_card.dart';
import 'widgets/smart_money_card.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          SizedBox(height: 18),

          AiDecisionCard(),
          SizedBox(height: 18),

          MorningBriefCard(),
          SizedBox(height: 18),

          PusuScoreCard(),
          SizedBox(height: 18),

          AiScoreCard(),
          SizedBox(height: 18),

          MarketMoneyFlowCard(),
          SizedBox(height: 18),

          InstitutionFlowCard(),
          SizedBox(height: 18),

          SectorHeatmapCard(),
          SizedBox(height: 18),

          ConsensusCard(),
          SizedBox(height: 18),

          OpportunityCard(),
          SizedBox(height: 18),

          SmartMoneyCard(),
          SizedBox(height: 18),

          NewsImpactCard(),
          SizedBox(height: 18),

          DisclaimerText(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Broker OS PRO',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Grafiği değil, paranın izini sür.',
          style: TextStyle(
            color: BrokerColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}