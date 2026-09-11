import 'package:flutter/material.dart';

import '../../widgets/adaptive_learning_card.dart';
import '../../widgets/ai_explainability_card.dart';
import '../../widgets/broker_council_card.dart';
import '../../widgets/broker_decision_dna_card.dart';
import '../../widgets/croc_ai_decision_card.dart';
import '../../widgets/croc_consensus_card.dart';
import '../common/analysis_category.dart';

class AiSection extends StatelessWidget {
  final String symbol;
  final dynamic crocDecision;
  final dynamic learningProfile;
  final dynamic council;
  final dynamic explainability;
  final dynamic decisionDna;
  final dynamic consensusEngine;
  final dynamic brokerCopilot;
  final dynamic timelineEngine;

  const AiSection({
    super.key,
    required this.symbol,
    required this.crocDecision,
    required this.learningProfile,
    required this.council,
    required this.explainability,
    required this.decisionDna,
    required this.consensusEngine,
    required this.brokerCopilot,
    required this.timelineEngine,
  });

  @override
  Widget build(BuildContext context) {
    return AnalysisCategory(
      icon: Icons.psychology_alt_rounded,
      title: 'AI Kararı ve Açıklaması',
      subtitle: 'Karar, güven, nedenler ve öğrenen AI.',
      children: [
        CrocAiDecisionCard(result: crocDecision),
        AdaptiveLearningCard(profile: learningProfile),
        CrocConsensusCard(
          symbol: symbol,
          consensusEngine: consensusEngine,
          brokerCopilot: brokerCopilot,
          timelineEngine: timelineEngine,
        ),
        AiExplainabilityCard(report: explainability),
        BrokerCouncilCard(result: council),
        BrokerDecisionDnaCard(dna: decisionDna),
      ],
    );
  }
}
