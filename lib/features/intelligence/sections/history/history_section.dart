import 'package:flutter/material.dart';

import '../../../../core/models/ai_decision.dart';
import '../../../../core/models/stock_analysis.dart';
import '../../widgets/ai_action_center_card.dart';
import '../../widgets/ai_confidence_card.dart';
import '../../widgets/ai_confidence_history_card.dart';
import '../../widgets/ai_confidence_index_card.dart';
import '../../widgets/ai_decision_change_card.dart';
import '../../widgets/ai_event_log_card.dart';
import '../../widgets/ai_event_stream_card.dart';
import '../../widgets/ai_live_status_card.dart';
import '../../widgets/ai_memory_card.dart';
import '../../widgets/ai_mission_card.dart';
import '../../widgets/ai_morning_brief_card.dart';
import '../../widgets/ai_performance_card.dart';
import '../../widgets/ai_pulse_card.dart';
import '../../widgets/ai_timeline_card.dart';
import '../../widgets/decision_timeline_card.dart';
import '../../widgets/live_data_foundation_card.dart';
import '../../widgets/live_provider_status_card.dart';
import '../../widgets/market_adapter_center_card.dart';
import '../../widgets/market_gateway_status_card.dart';
import '../common/analysis_category.dart';

class HistorySection extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision aiDecision;
  final dynamic council;
  final dynamic memoryEngine;
  final dynamic consensusEngine;
  final dynamic timelineEngine;
  final dynamic performanceEngine;

  const HistorySection({
    super.key,
    required this.stock,
    required this.aiDecision,
    required this.council,
    required this.memoryEngine,
    required this.consensusEngine,
    required this.timelineEngine,
    required this.performanceEngine,
  });

  @override
  Widget build(BuildContext context) {
    return AnalysisCategory(
      icon: Icons.history_rounded,
      title: 'Geçmiş, Performans ve Canlı Sistem',
      subtitle: 'Karar geçmişi, başarı oranı ve veri altyapısı.',
      children: [
        DecisionTimelineCard(
          symbol: stock.symbol,
          timelineEngine: timelineEngine,
        ),
        AiPerformanceCard(
          symbol: stock.symbol,
          timelineEngine: timelineEngine,
          performanceEngine: performanceEngine,
        ),
        AiMemoryCard(
          symbol: stock.symbol,
          decision: council.finalDecision,
          confidence: council.confidence,
          memoryEngine: memoryEngine,
        ),
        LiveProviderStatusCard(symbol: stock.symbol),
        MarketGatewayStatusCard(),
        LiveDataFoundationCard(symbol: stock.symbol),
        MarketAdapterCenterCard(symbol: stock.symbol),
        AiConfidenceIndexCard(
          symbol: stock.symbol,
          consensusEngine: consensusEngine,
        ),
        AiEventStreamCard(stock: stock, council: council),
        AiLiveStatusCard(stock: stock, decision: aiDecision),
        AiPulseCard(stock: stock, decision: aiDecision),
        AiActionCenterCard(stock: stock, decision: aiDecision),
        AiEventLogCard(stock: stock, decision: aiDecision),
        AiMorningBriefCard(stock: stock, decision: aiDecision),
        AiDecisionChangeCard(stock: stock, decision: aiDecision),
        AiConfidenceHistoryCard(decision: aiDecision),
        AiConfidenceCard(decision: aiDecision),
        AiMissionCard(decision: aiDecision),
        AiTimelineCard(timeline: aiDecision.timeline),
      ],
    );
  }
}
