import 'package:flutter/material.dart';

import '../../core/prediction/services/prediction_ledger_service.dart';

import '../../core/ai/council/broker_council_engine.dart';
import '../../core/analysis/croc_technical_analysis.dart';
import '../../core/ai/stock_decision_engine.dart';
import '../../core/alerts/ai_alarm_engine.dart';
import '../../core/consensus/consensus_engine.dart';
import '../../core/copilot/broker_copilot.dart';
import '../../core/decision/services/croc_decision_service.dart';
import '../../core/dna/broker_dna_engine.dart';
import '../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../core/engine/broker_engine.dart';
import '../../core/explainability/broker_explainability_engine.dart';
import '../../core/learning/services/adaptive_learning_service.dart';
import '../../core/memory/memory_engine.dart';
import '../../core/models/stock_analysis.dart';
import '../../core/performance/decision_accuracy_engine.dart';
import '../../core/radar/services/radar_service.dart';
import '../../core/timeline/decision_timeline_engine.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_page.dart';
import '../data_terminal/models/institutional_models.dart';
import '../data_terminal/repositories/institutional_repository.dart';
import '../mission/replay/ai_replay_screen.dart';
import 'sections/ai_engine/croc_ai_engine_section.dart';
import 'sections/common/decision_footer.dart';
import 'sections/common/planning_tools_section.dart';
import 'sections/common/quick_decision_strip.dart';
import 'sections/common/view_mode_selector.dart';
import 'sections/professional_analysis_section.dart';
import 'widgets/croc_prediction_ledger_card.dart';
import 'widgets/croc_prediction_shadow_card.dart';
import 'widgets/ai_technical_terminal.dart';
import 'widgets/beginner_stock_header.dart';
import 'widgets/next_step_card.dart';
import 'widgets/simple_stock_decision_card.dart';
import 'widgets/simple_trade_plan_card.dart';

class BrokerIntelligenceScreen extends StatefulWidget {
  final String symbol;

  const BrokerIntelligenceScreen({super.key, required this.symbol});

  @override
  State<BrokerIntelligenceScreen> createState() =>
      _BrokerIntelligenceScreenState();
}

class _BrokerIntelligenceScreenState extends State<BrokerIntelligenceScreen> {
  bool _professionalMode = false;
  int _tabIndex = 0;

  final YahooBistMarketDataSource _marketSource = YahooBistMarketDataSource();

  final CrocTechnicalAnalysisEngine _technicalEngine =
      const CrocTechnicalAnalysisEngine();

  StockAnalysis? _liveStock;
  bool _liveLoading = true;
  String? _liveError;

  final InstitutionalRepository _institutionalRepository =
      InstitutionalRepository();

  Future<InstitutionalDataBundle>? _institutionalFuture;

  static const List<String> _tabs = [
    'Özet',
    'Derinlik',
    'İşlemler',
    'AKD',
    'Takas',
    'Grafiksel Takas',
    'Teknik',
    'CROC AI',
  ];

  @override
  void initState() {
    super.initState();
    _institutionalFuture = _institutionalRepository.load(
      widget.symbol.trim().toUpperCase(),
    );
    _loadLiveStock();
  }

  @override
  void didUpdateWidget(covariant BrokerIntelligenceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol.trim().toUpperCase() !=
        widget.symbol.trim().toUpperCase()) {
      _tabIndex = 0;
      _institutionalFuture = _institutionalRepository.load(
        widget.symbol.trim().toUpperCase(),
      );
      _loadLiveStock();
    }
  }

  Future<void> _loadLiveStock() async {
    final normalizedSymbol = widget.symbol.trim().toUpperCase();

    setState(() {
      _liveLoading = true;
      _liveError = null;
    });
    try {
      final snapshot = await _marketSource.fetch(
        normalizedSymbol,
        range: '1y',
        interval: '1d',
      );

      final analysis = _technicalEngine.analyze(snapshot.candles);
      final livePrice = snapshot.tick.price;

      final target1 = analysis.target;
      final targetDistance = target1 > livePrice
          ? target1 - livePrice
          : analysis.atr * 2.0;
      final target2 = livePrice + (targetDistance * 1.6);

      final live = StockAnalysis(
        symbol: normalizedSymbol,
        company: normalizedSymbol,
        aiScore: analysis.score,
        decision: analysis.decision,
        entry: livePrice,
        target1: target1,
        target2: target2,
        stop: analysis.stop,
        confidence: analysis.score,
        risk: analysis.risk,
        reasons: <String>[
          'CROC canlı piyasa verisi ile analiz edildi.',
          'Trend: ',
          'Risk/Getiri: ',
          ...analysis.reasons.take(2),
        ],
        lastPrice: livePrice,
        dailyChange: snapshot.tick.changePercent,
        volume: snapshot.tick.volume,
        firstInstitution: null,
        secondInstitution: null,
        thirdInstitution: null,
        smartMoneyFlow: null,
        technicalScore: analysis.score,
        smartMoneyScore: 0,
        institutionalScore: 0,
        newsScore: 0,
        riskScore: _riskScoreFromAnalysis(analysis),
        momentumScore: _momentumScoreFromAnalysis(analysis),
      );

      if (!mounted || widget.symbol.trim().toUpperCase() != normalizedSymbol) {
        return;
      }

      setState(() {
        _liveStock = live;
        _liveLoading = false;
      });

      await PredictionLedgerService.instance.captureAndReconcile(live);
    } catch (error) {
      if (!mounted || widget.symbol.trim().toUpperCase() != normalizedSymbol) {
        return;
      }

      setState(() {
        _liveStock = null;
        _liveLoading = false;
        _liveError = error.toString();
      });
    }
  }

  int _momentumScoreFromAnalysis(CrocTechnicalAnalysis analysis) {
    var score = 50;

    if (analysis.rsi >= 50 && analysis.rsi <= 68) {
      score += 15;
    } else if (analysis.rsi > 75) {
      score -= 10;
    } else if (analysis.rsi < 35) {
      score -= 15;
    }

    if (analysis.macdHistogram > 0) {
      score += 20;
    } else if (analysis.macdHistogram < 0) {
      score -= 20;
    }

    if (analysis.volumeRatio >= 1.20) {
      score += 15;
    } else if (analysis.volumeRatio < 0.70) {
      score -= 10;
    }

    final trend = analysis.trend.toLowerCase();

    if (trend.contains('yüks')) {
      score += 10;
    } else if (trend.contains('düş')) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  int _riskScoreFromAnalysis(CrocTechnicalAnalysis analysis) {
    final risk = analysis.risk.toLowerCase();

    if (risk.contains('yüksek')) return 75;
    if (risk.contains('orta')) return 50;
    if (risk.contains('düşük')) return 25;

    return 50;
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSymbol = widget.symbol.trim().toUpperCase();

    final fallbackStock = BrokerEngine.run().firstWhere(
      (item) => item.symbol.toUpperCase() == normalizedSymbol,
      orElse: () => RadarService.instance.buildAnalysis(normalizedSymbol),
    );

    final stock = _liveStock ?? fallbackStock;

    final aiDecision = StockDecisionEngine.analyze(stock);
    final crocDecision = CrocDecisionService.instance.analyze(stock);
    final learningProfile = AdaptiveLearningService.instance.profileFor(
      stock: stock,
      decision: crocDecision,
    );
    final council = BrokerCouncilEngine.evaluate(stock);
    final explainability = BrokerExplainabilityEngine.analyze(
      stock: stock,
      council: council,
    );
    final decisionDna = BrokerDnaEngine.analyze(stock: stock, council: council);

    return Scaffold(
      backgroundColor: BrokerColors.background,
      body: BrokerPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Geri'),
              style: TextButton.styleFrom(
                foregroundColor: BrokerColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            if (_liveLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: BrokerColors.primary,
                backgroundColor: BrokerColors.cardDeep,
              ),
            if (_liveLoading) const SizedBox(height: 8),
            if (_liveError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Canlı veri alınamadı; yedek analiz gösteriliyor.',
                  style: TextStyle(
                    color: BrokerColors.red.withValues(alpha: .85),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            BeginnerStockHeader(stock: stock),
            const SizedBox(height: 12),
            _buildTerminalTabs(),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey<int>(_tabIndex),
                child: switch (_tabIndex) {
                  0 => _buildOverview(stock: stock, crocDecision: crocDecision),
                  1 => _buildInstitutionalTab(
                    icon: Icons.view_stream_rounded,
                    title: 'DERİNLİK',
                    fields: const [
                      'Kademe',
                      'Alış fiyatı',
                      'Alış lotu',
                      'Satış fiyatı',
                      'Satış lotu',
                    ],
                  ),
                  2 => _buildInstitutionalTab(
                    icon: Icons.swap_horiz_rounded,
                    title: 'İŞLEMLER',
                    fields: const [
                      'Saat',
                      'Fiyat',
                      'Lot',
                      'Alan kurum',
                      'Satan kurum',
                    ],
                  ),
                  3 => _buildInstitutionalTab(
                    icon: Icons.account_balance_rounded,
                    title: 'ARACI KURUM DAĞILIMI',
                    fields: const ['Kurum', 'Alış', 'Satış', 'Net', 'Pay %'],
                  ),
                  4 => _buildInstitutionalTab(
                    icon: Icons.stacked_bar_chart_rounded,
                    title: 'TAKAS',
                    fields: const [
                      'Kurum',
                      'Mevcut lot',
                      'Önceki lot',
                      'Değişim',
                      'Pay %',
                    ],
                  ),
                  5 => _buildInstitutionalTab(
                    icon: Icons.multiline_chart_rounded,
                    title: 'GRAFİKSEL TAKAS',
                    fields: const [
                      'Kurum seçimi',
                      'Tarih',
                      'Lot',
                      'Pay %',
                      'Değişim eğrisi',
                    ],
                  ),
                  6 => AiTechnicalTerminal(stock: stock),
                  7 => _buildCrocAi(
                    stock: stock,
                    aiDecision: aiDecision,
                    crocDecision: crocDecision,
                    learningProfile: learningProfile,
                    council: council,
                    explainability: explainability,
                    decisionDna: decisionDna,
                  ),
                  _ => _buildOverview(stock: stock, crocDecision: crocDecision),
                },
              ),
            ),
            const SizedBox(height: 18),
            const DecisionFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border.withValues(alpha: .85)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = index == _tabIndex;

            return Padding(
              padding: EdgeInsets.only(
                right: index == _tabs.length - 1 ? 0 : 7,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? BrokerColors.primary.withValues(alpha: .16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected
                          ? BrokerColors.primary
                          : BrokerColors.borderSoft,
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: selected
                          ? BrokerColors.primary
                          : BrokerColors.textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOverview({
    required dynamic stock,
    required dynamic crocDecision,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickDecisionStrip(result: crocDecision),
        const SizedBox(height: 14),
        SimpleStockDecisionCard(result: crocDecision),
        const SizedBox(height: 16),
        CrocAiEngineSection(stock: stock, decision: crocDecision),
        const SizedBox(height: 16),
        CrocPredictionShadowCard(stock: stock),
        const SizedBox(height: 16),
        CrocPredictionLedgerCard(symbol: stock.symbol),
        const SizedBox(height: 16),
        SimpleTradePlanCard(stock: stock),
        const SizedBox(height: 16),
        NextStepCard(stock: stock),
        const SizedBox(height: 16),
        PlanningToolsSection(stock: stock, crocDecision: crocDecision),
      ],
    );
  }

  Widget _buildCrocAi({
    required dynamic stock,
    required dynamic aiDecision,
    required dynamic crocDecision,
    required dynamic learningProfile,
    required dynamic council,
    required dynamic explainability,
    required dynamic decisionDna,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewModeSelector(
          professionalMode: _professionalMode,
          onChanged: (value) {
            setState(() {
              _professionalMode = value;
            });
          },
        ),
        const SizedBox(height: 12),
        QuickDecisionStrip(result: crocDecision),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AiReplayScreen(stock: stock)),
              );
            },
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text('${stock.symbol} CROC AI ANALİZİNİ OYNAT'),
            style: FilledButton.styleFrom(
              backgroundColor: BrokerColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _professionalMode
              ? Column(
                  key: const ValueKey('professional'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AiTechnicalTerminal(stock: stock),
                    const SizedBox(height: 16),
                    ProfessionalAnalysisSection(
                      stock: stock,
                      aiDecision: aiDecision,
                      crocDecision: crocDecision,
                      learningProfile: learningProfile,
                      council: council,
                      explainability: explainability,
                      decisionDna: decisionDna,
                      memoryEngine: MemoryEngine.instance,
                      alarmEngine: AiAlarmEngine.instance,
                      consensusEngine: ConsensusEngine.instance,
                      brokerCopilot: BrokerCopilot.instance,
                      timelineEngine: DecisionTimelineEngine.instance,
                      performanceEngine: DecisionAccuracyEngine.instance,
                    ),
                  ],
                )
              : Column(
                  key: const ValueKey('simple'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleStockDecisionCard(result: crocDecision),
                    const SizedBox(height: 16),
                    CrocAiEngineSection(stock: stock, decision: crocDecision),
        const SizedBox(height: 16),
        CrocPredictionShadowCard(stock: stock),
        const SizedBox(height: 16),
        CrocPredictionLedgerCard(symbol: stock.symbol),
        const SizedBox(height: 16),
                    SimpleTradePlanCard(stock: stock),
                    const SizedBox(height: 16),
                    NextStepCard(stock: stock),
                    const SizedBox(height: 16),
                    PlanningToolsSection(
                      stock: stock,
                      crocDecision: crocDecision,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildInstitutionalTab({
    required IconData icon,
    required String title,
    required List<String> fields,
  }) {
    return FutureBuilder<InstitutionalDataBundle>(
      future: _institutionalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BrokerColors.cardDeep.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BrokerColors.border.withValues(alpha: .90),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: BrokerColors.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ProviderBanner(data: data),
              const SizedBox(height: 14),
              const Text(
                'VERİ ŞEMASI HAZIR',
                style: TextStyle(
                  color: BrokerColors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fields
                    .map(
                      (field) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: BrokerColors.backgroundSoft,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: BrokerColors.borderSoft),
                        ),
                        child: Text(
                          field,
                          style: const TextStyle(
                            color: BrokerColors.textSoft,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderBanner extends StatelessWidget {
  final InstitutionalDataBundle? data;

  const _ProviderBanner({required this.data});

  int _momentumScoreFromAnalysis(CrocTechnicalAnalysis analysis) {
    var score = 50;

    if (analysis.rsi >= 50 && analysis.rsi <= 68) {
      score += 15;
    } else if (analysis.rsi > 75) {
      score -= 10;
    } else if (analysis.rsi < 35) {
      score -= 15;
    }

    if (analysis.macdHistogram > 0) {
      score += 20;
    } else if (analysis.macdHistogram < 0) {
      score -= 20;
    }

    if (analysis.volumeRatio >= 1.20) {
      score += 15;
    } else if (analysis.volumeRatio < 0.70) {
      score -= 10;
    }

    final trend = analysis.trend.toLowerCase();

    if (trend.contains('yüks')) {
      score += 10;
    } else if (trend.contains('düş')) {
      score -= 10;
    }

    return score.clamp(0, 100);
  }

  int _riskScoreFromAnalysis(CrocTechnicalAnalysis analysis) {
    final risk = analysis.risk.toLowerCase();

    if (risk.contains('yüksek')) return 75;
    if (risk.contains('orta')) return 50;
    if (risk.contains('düşük')) return 25;

    return 50;
  }

  @override
  Widget build(BuildContext context) {
    final connected = data?.providerConnected == true;
    final color = connected ? BrokerColors.green : BrokerColors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            connected ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.providerName ?? 'Kurumsal veri sağlayıcısı',
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data?.statusMessage ?? 'Bağlantı durumu kontrol ediliyor.',
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



