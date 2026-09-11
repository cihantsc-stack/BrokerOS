import 'package:flutter/material.dart';

import '../../../../core/models/ai_decision.dart';
import '../../widgets/ai_alarm_center_card.dart';
import '../../widgets/ai_scenario_simulator_card.dart';
import '../../widgets/ai_warning_card.dart';
import '../../widgets/risk_reward_card.dart';
import '../../widgets/stability_gauge_card.dart';
import '../common/analysis_category.dart';

class RiskSection extends StatelessWidget {
  final String symbol;
  final AiDecision aiDecision;
  final dynamic alarmEngine;
  final dynamic memoryEngine;

  const RiskSection({
    super.key,
    required this.symbol,
    required this.aiDecision,
    required this.alarmEngine,
    required this.memoryEngine,
  });

  @override
  Widget build(BuildContext context) {
    return AnalysisCategory(
      icon: Icons.monitor_heart_outlined,
      title: 'Risk, Senaryo ve Alarm',
      subtitle: 'Olası senaryolar, risk dengesi ve uyarılar.',
      children: [
        AiScenarioSimulatorCard(symbol: symbol),
        RiskRewardCard(symbol: symbol),
        AiAlarmCenterCard(symbol: symbol, alarmEngine: alarmEngine),
        StabilityGaugeCard(symbol: symbol, memoryEngine: memoryEngine),
        AiWarningCard(decision: aiDecision),
      ],
    );
  }
}
