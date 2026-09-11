import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'ai/ai_section.dart';
import 'history/history_section.dart';
import 'money/money_section.dart';
import 'risk/risk_section.dart';
import 'technical/technical_section.dart';
import 'value/value_section.dart';
import 'common/analysis_category.dart';

class ProfessionalAnalysisSection extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision aiDecision;
  final dynamic crocDecision;
  final dynamic learningProfile;
  final dynamic council;
  final dynamic explainability;
  final dynamic decisionDna;
  final dynamic memoryEngine;
  final dynamic alarmEngine;
  final dynamic consensusEngine;
  final dynamic brokerCopilot;
  final dynamic timelineEngine;
  final dynamic performanceEngine;

  const ProfessionalAnalysisSection({
    super.key,
    required this.stock,
    required this.aiDecision,
    required this.crocDecision,
    required this.learningProfile,
    required this.council,
    required this.explainability,
    required this.decisionDna,
    required this.memoryEngine,
    required this.alarmEngine,
    required this.consensusEngine,
    required this.brokerCopilot,
    required this.timelineEngine,
    required this.performanceEngine,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal_rounded, color: BrokerColors.primary),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC TRADER MODE',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'AI, para akışı, teknik yapı, risk ve geçmiş tek terminalde.',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AiSection(
            symbol: stock.symbol,
            crocDecision: crocDecision,
            learningProfile: learningProfile,
            council: council,
            explainability: explainability,
            decisionDna: decisionDna,
            consensusEngine: consensusEngine,
            brokerCopilot: brokerCopilot,
            timelineEngine: timelineEngine,
          ),
          const SizedBox(height: 9),
          MoneySection(symbol: stock.symbol),
          const SizedBox(height: 9),
          TechnicalSection(stock: stock),
          const SizedBox(height: 9),
          AnalysisCategory(
            icon: Icons.diamond_outlined,
            title: 'Değer Yatırımı',
            subtitle: 'Şirket kalitesi, gerçek değer ve güvenlik marjı.',
            children: [ValueSection(stock: stock)],
          ),
          const SizedBox(height: 9),
          RiskSection(
            symbol: stock.symbol,
            aiDecision: aiDecision,
            alarmEngine: alarmEngine,
            memoryEngine: memoryEngine,
          ),
          const SizedBox(height: 9),
          HistorySection(
            stock: stock,
            aiDecision: aiDecision,
            council: council,
            memoryEngine: memoryEngine,
            consensusEngine: consensusEngine,
            timelineEngine: timelineEngine,
            performanceEngine: performanceEngine,
          ),
        ],
      ),
    );
  }
}
