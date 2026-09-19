import '../../../core/data_foundation/market/croc_data_quality.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/bist/database/bist_index_membership.dart';

import '../../../core/data_foundation/market/market_tick.dart';
import '../../../core/data_foundation/market/historical_candle.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/master_engine/croc_master_stock_engine.dart';
import '../../../core/trade/croc_scale_in_engine.dart';
import '../../../core/trade/croc_entry_timing_engine.dart';
import '../../../core/kap_intelligence/kap_intelligence_service.dart';
import '../../../core/funds/data_sources/stock_fund_radar_data_source.dart';
import '../../../core/funds/models/stock_fund_radar_result.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';

import '../widgets/croc_position_card.dart';
import '../widgets/croc_scale_in_plan_card.dart';
import '../widgets/croc_quick_view_card.dart';
import '../widgets/croc_fund_radar_card.dart';

class StockDetailScreen extends StatefulWidget {
  final String code;
  final String company;
  final double price;
  final double change;
  final int aiScore;

  const StockDetailScreen({
    super.key,
    required this.code,
    required this.company,
    required this.price,
    required this.change,
    required this.aiScore,
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  int selectedPeriod = 5;
  int selectedTab = 0;

  bool analysisRunning = false;
  int visibleAnalysisStep = 0;
  Timer? analysisTimer;

  MarketTick? _liveTick;
  List<HistoricalCandle> _liveCandles = const [];
  List<HistoricalCandle> _analysisCandles = const [];
  bool _liveLoading = true;
  String? _liveError;
  CrocTechnicalAnalysis? _analysis;
  CrocMasterStockResult? _masterResult;
  CrocEntryTimingResult? _entryTimingResult;
  KapIntelligenceResult _kapResult = KapIntelligenceResult.empty;
  StockFundRadarResult? _fundRadarResult;
  bool _fundRadarLoading = true;

  HistoricalCandle? _hoveredCandle;
  Offset? _hoverPosition;

  double get _displayPrice => _liveTick?.price ?? widget.price;
  double get _displayChange => _liveTick?.changePercent ?? widget.change;
  int get _displayAiScore =>
      _masterResult?.masterScore ?? _analysis?.score ?? 0;
  String get _displayDecision =>
      _masterResult?.masterDecision ?? _analysis?.decision ?? 'VERİ BEKLENİYOR';

  int get _displayConfidence => _masterResult?.masterConfidence ?? 0;
  bool get _hasDataIntegrityRisk {
    if (_liveCandles.length < 2) return false;

    final start = _liveCandles.length > 24 ? _liveCandles.length - 24 : 0;
    final recent = _liveCandles.sublist(start);

    for (var i = 1; i < recent.length; i++) {
      final previousClose = recent[i - 1].close;
      final currentOpen = recent[i].open;
      final currentClose = recent[i].close;

      if (previousClose <= 0 || currentOpen <= 0 || currentClose <= 0) {
        continue;
      }

      final openGapPercent =
          ((currentOpen - previousClose) / previousClose) * 100;
      final closeGapPercent =
          ((currentClose - previousClose) / previousClose) * 100;

      if (openGapPercent.abs() > 10.5 || closeGapPercent.abs() > 10.5) {
        return true;
      }
    }

    return false;
  }

  final List<String> periods = const ['1G', '5G', '15G', '1A', '3A', '1Y'];

  final List<String> tabs = const [
    'Genel Bakış',
    'Teknik Analiz',
    'Kurumsal İşlemler',
    'Haberler',
    'Finansallar',
  ];

  String get _displayAnalysisReason {
    final master = _masterResult;

    if (master != null && master.masterReasons.isNotEmpty) {
      return master.masterReasons.take(2).join(' • ');
    }

    final analysis = _analysis;

    if (analysis != null && analysis.reasons.isNotEmpty) {
      return analysis.reasons.take(2).join(' • ');
    }

    return 'CROC karar gerekçelerini hazırlıyor.';
  }

  List<_AnalysisStep> get analysisSteps => [
    _AnalysisStep(
      icon: Icons.trending_up_rounded,
      title: 'Trend inceleniyor',
      result: _analysis == null
          ? 'Veri bekleniyor'
          : '${_analysis!.trend} • EMA20 ${_analysis!.ema20.toStringAsFixed(2)}',
    ),
    _AnalysisStep(
      icon: Icons.show_chart_rounded,
      title: 'Momentum hesaplanıyor',
      result: _analysis == null
          ? 'Veri bekleniyor'
          : 'RSI ${_analysis!.rsi.toStringAsFixed(1)} • MACD ${_analysis!.macd.toStringAsFixed(2)}',
    ),
    _AnalysisStep(
      icon: Icons.bar_chart_rounded,
      title: 'Hacim doğrulanıyor',
      result: _analysis == null
          ? 'Veri bekleniyor'
          : 'Ortalamanın ${(_analysis!.volumeRatio * 100).toStringAsFixed(0)}%',
    ),
    _AnalysisStep(
      icon: Icons.horizontal_rule_rounded,
      title: 'Seviyeler hesaplanıyor',
      result: _analysis == null
          ? 'Veri bekleniyor'
          : 'Destek ${_analysis!.support.toStringAsFixed(2)} • Direnç ${_analysis!.resistance.toStringAsFixed(2)}',
    ),
    _AnalysisStep(
      icon: Icons.shield_outlined,
      title: 'Risk hesaplanıyor',
      result: _analysis == null
          ? 'Veri bekleniyor'
          : '${_analysis!.risk} • ATR ${_analysis!.atr.toStringAsFixed(2)}',
    ),
    _AnalysisStep(
      icon: Icons.auto_awesome_rounded,
      title: 'CROC AI kararı',
      result: _displayDecision,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveQuote();
    _loadFundRadar();
  }

  Future<void> _loadFundRadar() async {
    if (mounted) {
      setState(() {
        _fundRadarLoading = true;
      });
    }

    try {
      final result = await StockFundRadarDataSource().fetch(widget.code);

      if (!mounted) return;

      setState(() {
        _fundRadarResult = result;
        _fundRadarLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _fundRadarResult = StockFundRadarResult.unavailable(
          symbol: widget.code,
          status: 'Fon Radarı verisi alınamadı.',
        );

        _fundRadarLoading = false;
      });
    }
  }

  String _rangeForPeriod(int index) {
    switch (index) {
      case 0:
        return '1d';
      case 1:
        return '5d';
      case 2:
        return '1mo';
      case 3:
        return '1mo';
      case 4:
        return '3mo';
      case 5:
      default:
        return '1y';
    }
  }

  String _intervalForPeriod(int index) {
    switch (index) {
      case 0:
        return '5m';
      case 1:
        return '15m';
      default:
        return '1d';
    }
  }

  int? _limitForPeriod(int index) {
    if (index == 2) return 15;
    return null;
  }

  Future<void> _changePeriod(int index) async {
    if (selectedPeriod == index && _liveCandles.isNotEmpty) return;
    setState(() {
      selectedPeriod = index;
      _hoveredCandle = null;
      _hoverPosition = null;
    });
    await _loadLiveQuote();
  }

  Future<void> _loadLiveQuote() async {
    setState(() {
      _liveLoading = true;
      _liveError = null;
    });

    try {
      final source = YahooBistMarketDataSource();

      // 1) GRAFİK VERİSİ
      // Kullanıcının seçtiği periyoda göre gelir.
      final snapshot = await source.fetch(
        widget.code,
        range: _rangeForPeriod(selectedPeriod),
        interval: _intervalForPeriod(selectedPeriod),
      );

      final tick = snapshot.tick;

      var candles = snapshot.candles;

      final limit = _limitForPeriod(selectedPeriod);

      if (limit != null && candles.length > limit) {
        candles = candles.sublist(candles.length - limit);
      }

      // 2) CROC AI ANALİZ VERİSİ
      // Grafik periyodundan bağımsız olarak 1 yıllık günlük veri kullanılır.
      List<HistoricalCandle> analysisCandles = const [];

      try {
        final analysisSnapshot = await source.fetch(
          widget.code,
          range: '1y',
          interval: '1d',
        );

        analysisCandles = analysisSnapshot.candles;
      } catch (_) {
        // Ayrı analiz verisi alınamazsa mevcut mumları kullanmayı dene.
        analysisCandles = snapshot.candles;
      }

      CrocTechnicalAnalysis? calculatedAnalysis;
      CrocMasterStockResult? calculatedMasterResult;
      CrocEntryTimingResult? calculatedEntryTiming;

      // -------------------------------------------------------
      // GERÇEK KAP INTELLIGENCE
      // -------------------------------------------------------
      //
      // KAP servisi bağımsız çalışır.
      // KAP erişilemezse teknik analiz ve CROC motoru durmaz.
      //
      KapIntelligenceResult kapResult = KapIntelligenceResult.empty;

      try {
        kapResult = await KapIntelligenceService.instance.analyzeSymbol(
          widget.code,
        );
      } catch (_) {
        kapResult = KapIntelligenceResult.empty;
      }

      if (analysisCandles.length >= 20) {
        calculatedAnalysis = const CrocTechnicalAnalysisEngine().analyze(
          analysisCandles,
          currentPrice: tick.price,
        );

        calculatedMasterResult = CrocMasterStockEngine.evaluate(
          symbol: widget.code,
          company: widget.company,
          lastPrice: tick.price,
          technical: calculatedAnalysis,
          dailyChange: tick.changePercent,
          dataQualityScore: CrocDataQualityEngine.evaluate(
            analysisCandles,
          ).score,
          volume: tick.volume,

          // Gerçek MKK / KAP etki skoru.
          // Veri yoksa 0 gelir ve Master karara dahil etmez.
          newsScore: kapResult.hasData ? kapResult.score : 0,
        );

        calculatedEntryTiming = CrocEntryTimingEngine.evaluate(
          lastPrice: tick.price,
          technical: calculatedAnalysis,
          master: calculatedMasterResult,
        );
      }

      if (!mounted) return;

      setState(() {
        _liveTick = tick;

        // Ekrandaki grafik seçilen periyotta kalır.
        _liveCandles = candles;

        // RSI / MACD / CROC motoru uzun analiz tarihçesini kullanır.
        _analysisCandles = analysisCandles;

        // AI ise uzun tarihçeden hesaplanır.
        _analysis = calculatedAnalysis;
        _masterResult = calculatedMasterResult;
        _entryTimingResult = calculatedEntryTiming;
        _kapResult = kapResult;

        _liveLoading = false;
        _hoveredCandle = null;
        _hoverPosition = null;

        if (analysisCandles.length < 20) {
          _liveError =
              'CROC AI analizi için yeterli geçmiş veri bulunamadı '
              '(${analysisCandles.length}/20 mum).';
        }
      });

      // Gerçek analiz hazır olduğunda CROC AI adımlarını otomatik başlat.
      // Böylece ekran "ANALİZ BEKLİYOR" durumunda takılı kalmaz.
      if (calculatedAnalysis != null && mounted) {
        Future.microtask(runAnalysis);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _liveLoading = false;
        _liveError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    analysisTimer?.cancel();
    super.dispose();
  }

  void runAnalysis() {
    // Analiz verisi henüz oluşmadıysa sahte bir animasyon oynatma.
    if (_analysis == null || !mounted) return;

    analysisTimer?.cancel();

    setState(() {
      analysisRunning = true;
      visibleAnalysisStep = 0;
    });

    analysisTimer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        visibleAnalysisStep++;
      });

      if (visibleAnalysisStep >= analysisSteps.length) {
        timer.cancel();

        Future.delayed(const Duration(milliseconds: 250), () {
          if (!mounted) return;

          setState(() {
            analysisRunning = false;
          });
        });
      }
    });
  }

  List<double> _buildRealRsiSeries() {
    if (_analysisCandles.length < 15) {
      return const [];
    }

    final closes = _analysisCandles
        .map((candle) => candle.close)
        .toList(growable: false);

    const period = 14;
    final result = <double>[];

    for (var end = period; end < closes.length; end++) {
      var gains = 0.0;
      var losses = 0.0;

      for (var i = end - period + 1; i <= end; i++) {
        final difference = closes[i] - closes[i - 1];

        if (difference >= 0) {
          gains += difference;
        } else {
          losses -= difference;
        }
      }

      final averageGain = gains / period;
      final averageLoss = losses / period;

      if (averageLoss == 0) {
        result.add(100);
      } else {
        final rs = averageGain / averageLoss;
        result.add(100 - (100 / (1 + rs)));
      }
    }

    return result;
  }

  double _indicatorEma(List<double> values, int period) {
    if (values.isEmpty) {
      return 0;
    }

    final p = math.max(1, math.min(period, values.length));
    final k = 2.0 / (p + 1);

    var ema = values.take(p).reduce((a, b) => a + b) / p;

    for (var i = p; i < values.length; i++) {
      ema = values[i] * k + ema * (1 - k);
    }

    return ema;
  }

  List<double> _indicatorEmaSeries(List<double> values, int period) {
    if (values.isEmpty) {
      return const [];
    }

    final result = <double>[];
    final k = 2.0 / (period + 1);
    var ema = values.first;

    for (final value in values) {
      ema = value * k + ema * (1 - k);
      result.add(ema);
    }

    return result;
  }

  _RealMacdSeries _buildRealMacdSeries() {
    if (_analysisCandles.length < 26) {
      return const _RealMacdSeries(macd: [], signal: [], histogram: []);
    }

    final closes = _analysisCandles
        .map((candle) => candle.close)
        .toList(growable: false);

    final macdValues = <double>[];
    final signalValues = <double>[];
    final histogramValues = <double>[];

    for (var end = 25; end < closes.length; end++) {
      final prefix = closes.sublist(0, end + 1);

      final macd = _indicatorEma(prefix, 12) - _indicatorEma(prefix, 26);

      final fast = _indicatorEmaSeries(prefix, 12);
      final slow = _indicatorEmaSeries(prefix, 26);

      final macdHistory = List<double>.generate(
        prefix.length,
        (index) => fast[index] - slow[index],
        growable: false,
      );

      final signal = _indicatorEma(
        macdHistory,
        math.min(9, macdHistory.length),
      );

      macdValues.add(macd);
      signalValues.add(signal);
      histogramValues.add(macd - signal);
    }

    return _RealMacdSeries(
      macd: macdValues,
      signal: signalValues,
      histogram: histogramValues,
    );
  }

  String _formatCompactVolume(double value) {
    if (value <= 0) {
      return '—';
    }

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }

  String _formatTime(DateTime value) {
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    final s = value.second.toString().padLeft(2, '0');
    return 'Son güncelleme $h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final mobile = availableWidth < 850;
        final compactDesktop = availableWidth < 1180;

        return Scaffold(
          backgroundColor: const Color(0xFF020605),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(mobile),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      mobile ? 12 : 18,
                      6,
                      mobile ? 12 : 18,
                      30,
                    ),
                    child: Column(
                      children: [
                        _buildStockHeader(mobile),
                        if (_hasDataIntegrityRisk) ...[
                          const SizedBox(height: 8),
                          _buildDataRiskBanner(mobile),
                        ],
                        const SizedBox(height: 10),

                        // CROC önce sonucu söyler.
                        _buildCrocDecisionHero(mobile),
                        CrocQuickViewCard(
                          price: _displayPrice,
                          technical: _analysis,
                          master: _masterResult,
                          kap: _kapResult,
                        ),
                        if (_analysis != null &&
                            _displayDecision.toUpperCase().contains('AL'))
                          CrocScaleInPlanCard(
                            currentPrice: _displayPrice,
                            analysis: _analysis!,
                          ),

                        CrocPositionCard(
                          symbol: widget.code,
                          currentPrice: _displayPrice,
                          masterScore: _displayAiScore,
                          riskLabel: _analysis?.risk ?? '',
                          stop: _analysis?.stop ?? 0,
                          target: _analysis?.target ?? 0,
                        ),
                        const SizedBox(height: 10),
                        CrocFundRadarCard(
                          result: _fundRadarResult,
                          loading: _fundRadarLoading,
                        ),

                        _buildPeriodBar(mobile || compactDesktop),
                        const SizedBox(height: 10),

                        // Ana çalışma alanı: canlı mumlar + gerçek hedef/stop.
                        _buildMainChartAreaV2(mobile || compactDesktop),

                        const SizedBox(height: 14),

                        // Teknik ayrıntılar ilk bakışta kullanıcıyı boğmaz.
                        // İsteyen yatırımcı tek dokunuşla derine iner.
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF06130F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF1C4B39),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ExpansionTile(
                                initiallyExpanded: false,
                                tilePadding: EdgeInsets.symmetric(
                                  horizontal: mobile ? 14 : 18,
                                  vertical: 4,
                                ),
                                childrenPadding: EdgeInsets.fromLTRB(
                                  mobile ? 10 : 14,
                                  0,
                                  mobile ? 10 : 14,
                                  14,
                                ),
                                iconColor: const Color(0xFF70F4AD),
                                collapsedIconColor: const Color(0xFF70F4AD),
                                leading: Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF70F4AD,
                                    ).withValues(alpha: .08),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFF70F4AD),
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  'DETAYLI ANALİZİ GÖR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .7,
                                  ),
                                ),
                                subtitle: const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'RSI • MACD • teknik göstergeler • KAP • finansallar',
                                    style: TextStyle(
                                      color: Color(0xFF8FA79D),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                children: [
                                  _buildIndicators(mobile),
                                  const SizedBox(height: 12),
                                  _buildTabs(mobile),
                                  const SizedBox(height: 12),
                                  _buildSelectedTabContent(
                                    mobile || compactDesktop,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(bool mobile) {
    return Container(
      height: mobile ? 62 : 72,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 22),
      decoration: const BoxDecoration(
        color: Color(0xFF04100C),
        border: Border(bottom: BorderSide(color: Color(0xFF173E30))),
      ),
      child: Row(
        children: [
          _SquareButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.star_rounded, color: Color(0xFFFFC857), size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.code,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mobile ? 20 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 7),
                _StockDetailBistIndexBadge(symbol: widget.code),
                Text(
                  widget.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF91A69D),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!mobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF071A13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1D5A41)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFF70F4AD), size: 9),
                  SizedBox(width: 7),
                  Text(
                    'BIST AÇIK',
                    style: TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStockHeader(bool mobile) {
    final positive = _displayChange >= 0;
    final changeColor = positive
        ? const Color(0xFF70F4AD)
        : const Color(0xFFFF6673);

    final priceArea = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 5,
            children: [
              Text(
                '${_displayPrice.toStringAsFixed(2)} ₺',
                style: TextStyle(
                  color: changeColor,
                  fontSize: mobile ? 30 : 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${positive ? '+' : ''}${_displayChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 22,
            runSpacing: 12,
            children: [
              _HeaderMetric(
                title: 'Yüksek',
                value: _liveCandles.isEmpty
                    ? '—'
                    : _liveCandles.last.high.toStringAsFixed(2),
              ),
              _HeaderMetric(
                title: 'Düşük',
                value: _liveCandles.isEmpty
                    ? '—'
                    : _liveCandles.last.low.toStringAsFixed(2),
                negative: true,
              ),
              _HeaderMetric(
                title: 'Hacim',
                value: _liveTick == null
                    ? '—'
                    : _formatCompactVolume(_liveTick!.volume),
              ),
              const _HeaderMetric(title: 'Piyasa Değeri', value: '—'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _liveError == null ? Icons.circle : Icons.error_outline_rounded,
                color: _liveError == null
                    ? const Color(0xFF70F4AD)
                    : const Color(0xFFFF6673),
                size: 9,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _liveLoading
                      ? 'CROC DATA GATEWAY • CANLI VERİ ALINIYOR...'
                      : _liveError != null
                      ? 'CANLI VERİ ALINAMADI • ${_liveError!}'
                      : mobile
                      ? 'CANLI • ${_formatTime(_liveTick!.timestamp).replaceFirst('Son güncelleme ', '')}'
                      : '${_liveTick!.source} • ${_formatTime(_liveTick!.timestamp)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _liveError == null
                        ? const Color(0xFF70F4AD)
                        : const Color(0xFFFF6673),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!_liveLoading)
                IconButton(
                  tooltip: 'Canlı veriyi yenile',
                  onPressed: _loadLiveQuote,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF91A69D),
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (mobile) {
      return Column(
        children: [
          Row(children: [priceArea]),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [priceArea],
    );
  }

  Widget _buildDataRiskBanner(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 11 : 13,
        vertical: mobile ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC857).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFC857).withValues(alpha: .38),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC857), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'VERİ RİSKİ YÜKSEK • Son fiyat serisinde olağandışı kopuş tespit edildi. '
              'Teknik göstergeleri, hedef ve stop seviyelerini daha temkinli değerlendir.',
              style: TextStyle(
                color: Color(0xFFFFD978),
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrocDecisionHero(bool mobile) {
    final ready = _analysis != null;
    final decision = ready ? _displayDecision : 'ANALİZ EDİLİYOR';
    final score = ready ? _displayAiScore : 0;
    final target = _analysis?.target;
    final stop = _analysis?.stop;
    final a = _analysis;

    // Canonical trade levels for the Hero now come from one Scale-In Engine.
    final scaleInPlan = a == null
        ? null
        : CrocScaleInEngine.build(currentPrice: _displayPrice, analysis: a);
    final buyLow = scaleInPlan?.first?.low;
    final buyHigh = scaleInPlan?.first?.high;

    final riskLabel = !ready ? '—' : a!.risk.toUpperCase();

    final decisionColor = !ready
        ? const Color(0xFF91A69D)
        : decision.toUpperCase().contains('AL')
        ? const Color(0xFF70F4AD)
        : decision.toUpperCase().contains('RİSK') ||
              decision.toUpperCase().contains('SAT')
        ? const Color(0xFFFF6673)
        : const Color(0xFFFFC857);

    final riskColor = riskLabel.contains('YÜKSEK')
        ? const Color(0xFFFF6673)
        : riskLabel.contains('ORTA')
        ? const Color(0xFFFFC857)
        : riskLabel == '—'
        ? const Color(0xFF91A69D)
        : const Color(0xFF70F4AD);

    Widget mobileMetric({
      required String label,
      required String value,
      required Color color,
      required IconData icon,
    }) {
      return Expanded(
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .055),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: color.withValues(alpha: .20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF71877D),
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget desktopMetric({
      required String label,
      required String value,
      required Color color,
      required IconData icon,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withValues(alpha: .20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF71877D),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final normalizedDecision = decision.toUpperCase();

    final String buyLabel;
    if (normalizedDecision == 'GÜÇLÜ AL' || normalizedDecision == 'AL') {
      buyLabel = 'ALIM';
    } else if (normalizedDecision == 'İZLE' || normalizedDecision == 'BEKLE') {
      buyLabel = 'İZLEME';
    } else {
      buyLabel = 'GİRİŞ YOK';
    }

    final buyText = buyLow == null || buyHigh == null
        ? '\u2014'
        : buyLow.toStringAsFixed(2) == buyHigh.toStringAsFixed(2)
        ? buyLow.toStringAsFixed(2)
        : '${buyLow.toStringAsFixed(2)}\u2013${buyHigh.toStringAsFixed(2)}';
    final targetText = target == null ? '—' : target.toStringAsFixed(2);
    final stopText = stop == null ? '—' : stop.toStringAsFixed(2);
    final rrText = a == null ? '—' : '1:${a.riskReward.toStringAsFixed(1)}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        mobile ? 12 : 17,
        mobile ? 11 : 14,
        mobile ? 12 : 17,
        mobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: ready
              ? decisionColor.withValues(alpha: .38)
              : const Color(0xFF1B4938),
        ),
        boxShadow: ready
            ? [
                BoxShadow(
                  color: decisionColor.withValues(alpha: .045),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF70F4AD).withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF70F4AD),
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CROC AI',
                style: TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (ready)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF70F4AD).withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GÜVEN %$_displayConfidence',
                    style: const TextStyle(
                      color: Color(0xFFA8BAB2),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: mobile ? 9 : 11),
          Text(
            decision,
            style: TextStyle(
              color: decisionColor,
              fontSize: mobile ? 29 : 32,
              height: .95,
              fontWeight: FontWeight.w900,
              letterSpacing: -.8,
            ),
          ),

          if (ready && _entryTimingResult != null) ...[
            SizedBox(height: mobile ? 10 : 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 10 : 12,
                vertical: mobile ? 9 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1B15),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFF274B3D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 17,
                    color: Color(0xFFFFC857),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GİRİŞ ZAMANLAMASI',
                          style: TextStyle(
                            color: Color(0xFF71877D),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _entryTimingResult!.decision,
                                style: TextStyle(
                                  color: _entryTimingResult!.canEnterNow
                                      ? const Color(0xFF70F4AD)
                                      : _entryTimingResult!.trainMissed
                                      ? const Color(0xFFFF6673)
                                      : const Color(0xFFFFC857),
                                  fontSize: mobile ? 13 : 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_entryTimingResult!.score}/100',
                              style: const TextStyle(
                                color: Color(0xFFA8BAB2),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _entryTimingResult!.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFA4B5AD),
                            fontSize: 9.5,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (ready) ...[
            SizedBox(height: mobile ? 6 : 7),
            Text(
              _displayAnalysisReason,
              maxLines: mobile ? 2 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA4B5AD),
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: mobile ? 9 : 12),
          if (mobile) ...[
            Row(
              children: [
                mobileMetric(
                  label: buyLabel,
                  value: buyText,
                  color: const Color(0xFF70F4AD),
                  icon: Icons.shopping_cart_checkout_rounded,
                ),
                const SizedBox(width: 7),
                mobileMetric(
                  label: 'HEDEF',
                  value: targetText,
                  color: const Color(0xFFFFC857),
                  icon: Icons.flag_rounded,
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                mobileMetric(
                  label: 'STOP',
                  value: stopText,
                  color: const Color(0xFFFF6673),
                  icon: Icons.gpp_bad_rounded,
                ),
                const SizedBox(width: 7),
                mobileMetric(
                  label: 'R / R',
                  value: rrText,
                  color: const Color(0xFF8FD8FF),
                  icon: Icons.balance_rounded,
                ),
              ],
            ),
          ] else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                desktopMetric(
                  label: buyLabel,
                  value: buyText,
                  color: const Color(0xFF70F4AD),
                  icon: Icons.shopping_cart_checkout_rounded,
                ),
                desktopMetric(
                  label: 'HEDEF',
                  value: targetText,
                  color: const Color(0xFFFFC857),
                  icon: Icons.flag_rounded,
                ),
                desktopMetric(
                  label: 'STOP',
                  value: stopText,
                  color: const Color(0xFFFF6673),
                  icon: Icons.gpp_bad_rounded,
                ),
                desktopMetric(
                  label: 'R / R',
                  value: rrText,
                  color: const Color(0xFF8FD8FF),
                  icon: Icons.balance_rounded,
                ),
              ],
            ),
          SizedBox(height: mobile ? 8 : 10),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9,
              vertical: mobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF081A14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF173E30)),
            ),
            child: Row(
              children: [
                const Text(
                  'RİSK',
                  style: TextStyle(
                    color: Color(0xFF81978D),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  riskLabel,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 13),
                const Text(
                  'MASTER',
                  style: TextStyle(
                    color: Color(0xFF81978D),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  ready ? '$score' : '—',
                  style: const TextStyle(
                    color: Color(0xFFB5C5BE),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.newspaper_rounded,
                  size: 12,
                  color: _kapResult.hasData
                      ? const Color(0xFF8FD8FF)
                      : const Color(0xFF64776F),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _kapResult.hasData
                        ? 'KAP ${_kapResult.score}/100'
                        : 'KAP VERİSİ YOK',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _kapResult.hasData
                          ? const Color(0xFF8FD8FF)
                          : const Color(0xFF81978D),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChartAreaV2(bool mobile) {
    // V2 ilk aşama:
    // mevcut çalışan grafik altyapısını aynen kullan.
    return _buildMainChartArea(mobile);
  }

  void _showIndicatorPanel() {
    final a = _analysis;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF07110E),
      barrierColor: Colors.black.withValues(alpha: .65),
      isScrollControlled: true,
      builder: (sheetContext) {
        Widget metric(String label, String value, Color tone) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tone.withValues(alpha: .24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF8FA79D),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tone,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.query_stats_rounded,
                      color: Color(0xFF70F4AD),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'TEKNİK GÖSTERGELER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF91A69D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (a == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'Teknik analiz henüz hazır değil.',
                      style: TextStyle(
                        color: Color(0xFFA6B8B0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      metric(
                        'RSI (14)',
                        a.rsi.toStringAsFixed(1),
                        const Color(0xFFC474FF),
                      ),
                      const SizedBox(width: 8),
                      metric(
                        'MACD',
                        a.macd.toStringAsFixed(2),
                        const Color(0xFF8FD8FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      metric(
                        'SİNYAL',
                        a.macdSignal.toStringAsFixed(2),
                        const Color(0xFFFFC857),
                      ),
                      const SizedBox(width: 8),
                      metric(
                        'HACİM',
                        '${a.volumeRatio.toStringAsFixed(2)}x',
                        const Color(0xFF70F4AD),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      metric(
                        'DESTEK',
                        a.support.toStringAsFixed(2),
                        const Color(0xFF53D99A),
                      ),
                      const SizedBox(width: 8),
                      metric(
                        'DİRENÇ',
                        a.resistance.toStringAsFixed(2),
                        const Color(0xFFFFC857),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1813),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF173E30)),
                    ),
                    child: Text(
                      'Trend: ${a.trend}',
                      style: const TextStyle(
                        color: Color(0xFFC4D2CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodBar(bool mobile) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF06100D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  periods.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _PeriodButton(
                      title: periods[index],
                      selected: selectedPeriod == index,
                      onTap: () => _changePeriod(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 10),
            _ActionButton(
              icon: Icons.query_stats_rounded,
              title: 'Gösterge',
              onTap: _showIndicatorPanel,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.auto_awesome_rounded,
              title: analysisRunning ? 'Analiz Ediliyor' : 'CROC AI Analizi',
              highlighted: true,
              onTap: runAnalysis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainChartArea(bool mobile) {
    final chart = Container(
      height: mobile ? 390 : 560,
      decoration: BoxDecoration(
        color: const Color(0xFF04100D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, chartConstraints) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.precise,
                    onExit: (_) {
                      if (!mounted) return;
                      setState(() {
                        _hoveredCandle = null;
                        _hoverPosition = null;
                      });
                    },
                    onHover: (event) {
                      if (_liveCandles.isEmpty) return;
                      final width = math.max(1.0, chartConstraints.maxWidth);
                      final rawIndex =
                          ((event.localPosition.dx / width) *
                                  _liveCandles.length)
                              .floor();
                      final index = rawIndex
                          .clamp(0, _liveCandles.length - 1)
                          .toInt();
                      setState(() {
                        _hoveredCandle = _liveCandles[index];
                        _hoverPosition = event.localPosition;
                      });
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _TechnicalChartPainter(
                        candles: _liveCandles,
                        hoveredCandle: mobile ? null : _hoveredCandle,
                        analysis: _analysis,
                      ),
                    ),
                  );
                },
              ),
            ),
            if (mobile)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03100C).withValues(alpha: .90),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF173E30)),
                    ),
                    child: const Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _GhostLegendDot(color: Color(0xFF53D99A), text: 'ALIM'),
                        _GhostLegendDot(color: Color(0xFFFF6673), text: 'STOP'),
                        _GhostLegendDot(
                          color: Color(0xFFFFC857),
                          text: 'HEDEF',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Positioned(
              left: mobile ? 12 : 18,
              top: mobile ? 10 : 15,
              child: Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  Text(
                    _liveCandles.isEmpty
                        ? 'A —'
                        : 'A ${_liveCandles.last.open.toStringAsFixed(2)}',
                    style: _chartInfoStyle,
                  ),
                  Text(
                    _liveCandles.isEmpty
                        ? 'Y —'
                        : 'Y ${_liveCandles.last.high.toStringAsFixed(2)}',
                    style: _chartInfoStyle,
                  ),
                  Text(
                    _liveCandles.isEmpty
                        ? 'D —'
                        : 'D ${_liveCandles.last.low.toStringAsFixed(2)}',
                    style: _chartInfoStyle,
                  ),
                  Text(
                    'K ${_displayPrice.toStringAsFixed(2)}',
                    style: _chartInfoStyle,
                  ),
                  Text(
                    '${_displayChange >= 0 ? '+' : ''}${_displayChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: _displayChange >= 0
                          ? const Color(0xFF70F4AD)
                          : const Color(0xFFFF6673),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (!mobile && _hoveredCandle != null && _hoverPosition != null)
              Positioned(
                left: math.min(_hoverPosition!.dx + 14, mobile ? 210 : 520),
                top: math.max(48, _hoverPosition!.dy - 76),
                child: IgnorePointer(
                  child: _CandleTooltip(
                    candle: _hoveredCandle!,
                    volumeText: _formatCompactVolume(_hoveredCandle!.volume),
                  ),
                ),
              ),
            if (_analysis != null && !mobile)
              Positioned(
                top: mobile ? 70 : 82,
                right: 14,
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _LevelBadge(
                        text: 'HEDEF ${_analysis!.target.toStringAsFixed(2)}',
                        color: const Color(0xFF70F4AD),
                      ),
                      const SizedBox(height: 44),
                      _LevelBadge(
                        text:
                            'DİRENÇ ${_analysis!.resistance.toStringAsFixed(2)}',
                        color: const Color(0xFFFFC857),
                      ),
                      const SizedBox(height: 52),
                      _LevelBadge(
                        text: 'DESTEK ${_analysis!.support.toStringAsFixed(2)}',
                        color: const Color(0xFF53D99A),
                      ),
                      const SizedBox(height: 8),
                      _LevelBadge(
                        text: 'STOP ${_analysis!.stop.toStringAsFixed(2)}',
                        color: const Color(0xFFFF6673),
                      ),
                    ],
                  ),
                ),
              ),
            if (!mobile)
              Positioned(
                top: mobile ? 115 : 130,
                left: mobile ? 100 : 270,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF241031),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: const Color(0xFFB85CFF)),
                  ),
                  child: Text(
                    _analysis == null
                        ? 'GERÇEK VERİ'
                        : 'TREND: ${_analysis!.trend.toUpperCase()}',
                    style: TextStyle(
                      color: Color(0xFFE0A3FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            if (!mobile)
              Positioned(
                left: mobile ? 115 : 430,
                bottom: mobile ? 74 : 105,
                child: Container(
                  width: mobile ? 170 : 220,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071712),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF236B49)),
                  ),
                  child: Text(
                    _analysis == null
                        ? 'CROC AI analiz için veriyi bekliyor'
                        : (_analysis!.reasons.isEmpty
                              ? 'Teknik veriler hesaplandı'
                              : _analysis!.reasons.first),
                    style: TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (mobile) {
      return Column(
        children: [
          chart,
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.auto_awesome_rounded,
            title: analysisRunning
                ? 'Analiz Ediliyor...'
                : 'CROC AI Analizini Oynat',
            highlighted: true,
            expanded: true,
            onTap: runAnalysis,
          ),
          if (analysisRunning || visibleAnalysisStep > 0) ...[
            const SizedBox(height: 12),
            _CrocAnalysisFlow(
              steps: analysisSteps,
              visibleStep: visibleAnalysisStep,
              running: analysisRunning,
              decision: _displayDecision,
              reasons: _analysis?.reasons ?? const [],
            ),
          ],
        ],
      );
    }

    return chart;
  }

  Widget _buildIndicators(bool mobile) {
    final realRsiSeries = _buildRealRsiSeries();
    final realMacdSeries = _buildRealMacdSeries();

    final rsi = Container(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFF04100D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: CustomPaint(
        painter: _RsiPainter(values: realRsiSeries),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Align(
            alignment: Alignment.topLeft,
            child: InteractiveGlossaryText(
              _analysis == null
                  ? 'RSI (14) —'
                  : 'RSI (14)   ${_analysis!.rsi.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFD59AFF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );

    final macd = Container(
      height: 145,
      decoration: BoxDecoration(
        color: const Color(0xFF04100D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: CustomPaint(
        painter: _MacdPainter(data: realMacdSeries),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Align(
            alignment: Alignment.topLeft,
            child: InteractiveGlossaryText(
              _analysis == null
                  ? 'MACD (12, 26) —'
                  : 'MACD ${_analysis!.macd.toStringAsFixed(2)}   Sinyal ${_analysis!.macdSignal.toStringAsFixed(2)}   Hist ${_analysis!.macdHistogram.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF91A69D),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );

    return Column(children: [rsi, const SizedBox(height: 10), macd]);
  }

  Widget _buildTabs(bool mobile) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF06100D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedTab == index;

            return Padding(
              padding: const EdgeInsets.only(right: 7),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                borderRadius: BorderRadius.circular(11),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0E3827)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF39B876)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF70F4AD)
                          : const Color(0xFF9AAEA5),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

  Widget _buildSelectedTabContent(bool mobile) {
    switch (selectedTab) {
      case 0:
        return _buildBottomSummary(mobile);
      case 1:
        return _buildTechnicalTab(mobile);
      case 2:
        return const _InfoTabPanel(
          icon: Icons.account_balance_rounded,
          title: 'Kurumsal İşlemler',
          message:
              'Bu sekme çalışıyor. Kurum dağılımı ve aracı kurum akışı için gerçek veri kaynağı henüz bağlanmadı; sahte veri göstermiyoruz.',
        );
      case 3:
        return const _InfoTabPanel(
          icon: Icons.newspaper_rounded,
          title: 'Haberler',
          message:
              'Bu sekme çalışıyor. KAP ve haber akışı bir sonraki veri bağlantısında canlı olarak eklenecek.',
        );
      case 4:
        return const _InfoTabPanel(
          icon: Icons.receipt_long_rounded,
          title: 'Finansallar',
          message:
              'Bu sekme çalışıyor. Bilanço, gelir tablosu ve temel oranlar için finansal veri kaynağı henüz bağlanmadı.',
        );
      default:
        return _buildBottomSummary(mobile);
    }
  }

  Widget _buildTechnicalTab(bool mobile) {
    final a = _analysis;
    if (a == null) {
      return const _InfoTabPanel(
        icon: Icons.query_stats_rounded,
        title: 'Teknik Analiz',
        message:
            'Seçilen periyotta teknik analiz için yeterli mum verisi bekleniyor.',
      );
    }

    final cards = <Widget>[
      _SummaryCard(
        title: 'RSI (14)',
        value: a.rsi.toStringAsFixed(1),
        subtitle: a.rsi >= 70
            ? 'Aşırı alım bölgesi.'
            : (a.rsi <= 30 ? 'Aşırı satım bölgesi.' : 'Nötr momentum bölgesi.'),
        icon: Icons.speed_rounded,
      ),
      _SummaryCard(
        title: 'MACD',
        value: a.macd.toStringAsFixed(2),
        subtitle:
            'Sinyal ${a.macdSignal.toStringAsFixed(2)} • Histogram ${a.macdHistogram.toStringAsFixed(2)}',
        icon: Icons.multiline_chart_rounded,
      ),
      _SummaryCard(
        title: 'EMA',
        value: '20: ${a.ema20.toStringAsFixed(2)}',
        subtitle: 'EMA50 ${a.ema50.toStringAsFixed(2)}',
        icon: Icons.show_chart_rounded,
      ),
      _SummaryCard(
        title: 'ATR / RİSK',
        value: a.atr.toStringAsFixed(2),
        subtitle: 'Risk: ${a.risk} • Skor ${a.score}/100',
        icon: Icons.shield_outlined,
      ),
    ];

    if (mobile) {
      return Column(
        children: cards
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards
          .map(
            (w) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: w,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomSummary(bool mobile) {
    final cards = [
      _SummaryCard(
        title: 'TREND',
        value: _analysis?.trend ?? 'Hesaplanıyor',
        subtitle: _analysis == null
            ? 'Gerçek mum verisi bekleniyor.'
            : 'EMA20 ${_analysis!.ema20.toStringAsFixed(2)} • EMA50 ${_analysis!.ema50.toStringAsFixed(2)}',
        icon: Icons.trending_up_rounded,
      ),
      _SummaryCard(
        title: 'DESTEKLER',
        value: _analysis == null
            ? 'Hesaplanıyor'
            : 'S1 ${_analysis!.support.toStringAsFixed(2)}',
        subtitle: _analysis == null
            ? 'Gerçek mum verisi bekleniyor.'
            : 'S2 ${_analysis!.support2.toStringAsFixed(2)} • S3 ${_analysis!.support3.toStringAsFixed(2)}',
        icon: Icons.horizontal_rule_rounded,
      ),
      _SummaryCard(
        title: 'DİRENÇLER',
        value: _analysis == null
            ? 'Hesaplanıyor'
            : 'R1 ${_analysis!.resistance.toStringAsFixed(2)}',
        subtitle: _analysis == null
            ? 'Gerçek mum verisi bekleniyor.'
            : 'R2 ${_analysis!.resistance2.toStringAsFixed(2)} • R3 ${_analysis!.resistance3.toStringAsFixed(2)}',
        icon: Icons.vertical_align_top_rounded,
      ),
      _SummaryCard(
        title: 'HACİM ANALİZİ',
        value: _analysis == null
            ? 'Hesaplanıyor'
            : '${_analysis!.volumeRatio.toStringAsFixed(2)}x',
        subtitle: 'Son hacmin 20 günlük ortalamaya oranı.',
        icon: Icons.bar_chart_rounded,
      ),
      _SummaryCard(
        title: 'HEDEFLER',
        value: _analysis == null
            ? 'Hesaplanıyor'
            : 'H1 ${_analysis!.target.toStringAsFixed(2)}',
        subtitle: _analysis == null
            ? 'Gerçek mum verisi bekleniyor.'
            : 'H2 ${_analysis!.target2.toStringAsFixed(2)} • H3 ${_analysis!.target3.toStringAsFixed(2)}',
        icon: Icons.flag_rounded,
      ),
      _SummaryCard(
        title: 'RİSK / GETİRİ',
        value: _analysis == null
            ? 'Hesaplanıyor'
            : '1 : ${_analysis!.riskReward.toStringAsFixed(1)}',
        subtitle: _analysis == null
            ? 'Stop ve hedef hesaplanıyor.'
            : 'Risk ${_analysis!.risk} • ATR ${_analysis!.atr.toStringAsFixed(2)}',
        icon: Icons.balance_rounded,
      ),
    ];

    if (mobile) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const gap = 10.0;
          final itemWidth = (constraints.maxWidth - gap) / 2;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cards
                .map((card) => SizedBox(width: itemWidth, child: card))
                .toList(),
          );
        },
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards
          .map(
            (card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: card,
              ),
            ),
          )
          .toList(),
    );
  }
}

const TextStyle _chartInfoStyle = TextStyle(
  color: Color(0xFF9FB2AA),
  fontSize: 10,
  fontWeight: FontWeight.w700,
);

class _HeaderMetric extends StatelessWidget {
  final String title;
  final String value;
  final bool negative;

  const _HeaderMetric({
    required this.title,
    required this.value,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF82978E), fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: negative ? const Color(0xFFFF6673) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF07130F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A4937)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF123F2D) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF3BC47C) : const Color(0xFF173E30),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xFF70F4AD) : const Color(0xFFA0B2AA),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool highlighted;
  final bool expanded;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.highlighted = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFF0C3425)
              : const Color(0xFF07130F),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: highlighted
                ? const Color(0xFF32B873)
                : const Color(0xFF1A4636),
          ),
        ),
        child: Row(
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: highlighted
                  ? const Color(0xFF70F4AD)
                  : const Color(0xFF9AADA5),
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                color: highlighted ? const Color(0xFF70F4AD) : Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class _LevelBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _LevelBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CandleTooltip extends StatelessWidget {
  final HistoricalCandle candle;
  final String volumeText;

  const _CandleTooltip({required this.candle, required this.volumeText});

  String _date(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day.$month.${d.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xEE06120E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A6E50)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _date(candle.time),
            style: const TextStyle(
              color: Color(0xFF70F4AD),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A ${candle.open.toStringAsFixed(2)}   Y ${candle.high.toStringAsFixed(2)}',
            style: _chartInfoStyle,
          ),
          Text(
            'D ${candle.low.toStringAsFixed(2)}   K ${candle.close.toStringAsFixed(2)}',
            style: _chartInfoStyle,
          ),
          const SizedBox(height: 4),
          Text(
            'Hacim $volumeText',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTabPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoTabPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF193F31)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF70F4AD), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF93A69E),
                    fontSize: 12,
                    height: 1.5,
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

class _AnalysisStep {
  final IconData icon;
  final String title;
  final String result;

  const _AnalysisStep({
    required this.icon,
    required this.title,
    required this.result,
  });
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF193F31)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InteractiveGlossaryText(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF899D94),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: const Color(0xFF70F4AD), size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF70F4AD),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF93A69E),
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalChartPainter extends CustomPainter {
  final List<HistoricalCandle> candles;
  final HistoricalCandle? hoveredCandle;
  final CrocTechnicalAnalysis? analysis;

  const _TechnicalChartPainter({
    required this.candles,
    this.hoveredCandle,
    this.analysis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF789088).withValues(alpha: 0.11)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += size.width / 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += size.height / 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (candles.isEmpty) return;
    final data = candles;
    double minP = data.first.low, maxP = data.first.high, maxV = 0;
    for (final c in data) {
      minP = math.min(minP, c.low);
      maxP = math.max(maxP, c.high);
      maxV = math.max(maxV, c.volume);
    }
    final pad = math.max((maxP - minP) * 0.08, 0.01);
    minP -= pad;
    maxP += pad;
    final chartTop = 42.0,
        chartBottom = size.height - 72.0,
        chartH = chartBottom - chartTop;
    // Son mum sağ kenara yapışmasın.
    // Grafik genişliğinin küçük bir kısmını gelecekteki fiyat alanı gibi bırakıyoruz.
    final plotWidth = size.width * 0.94;

    final renderData = data.length <= 90
        ? data
        : List.generate(
            90,
            (i) => data[((i * (data.length - 1)) / 89).round()],
          );

    final step = plotWidth / (renderData.length + 1);

    // Mumlar karar ekranında okunabilir kalsın fakat grafik analiz
    // terminali gibi aşırı kalınlaşmasın.
    final bodyW = math.max(2.4, math.min(9.0, step * 0.68));

    double py(double p) => chartTop + (maxP - p) / (maxP - minP) * chartH;

    // =========================================================
    // CROC GHOST ZONES
    // Gerçek teknik analiz seviyeleri mumların arkasına çizilir.
    // =========================================================
    final a = analysis;

    if (a != null) {
      void drawZone({
        required double low,
        required double high,
        required Color color,
      }) {
        final y1 = py(math.max(low, high));
        final y2 = py(math.min(low, high));

        final top = math.min(y1, y2);
        final bottom = math.max(y1, y2);

        canvas.drawRect(
          Rect.fromLTRB(0, top, size.width, bottom),
          Paint()..color = color.withValues(alpha: .09),
        );
      }

      void drawReferenceLevel({required double price, required Color color}) {
        final y = py(price);

        final paint = Paint()
          ..color = color.withValues(alpha: .22)
          ..strokeWidth = .75;

        // S1 / R1 yalnız referans çizgisi olarak kalır.
        // Etiket yok; ana karar seviyeleri HEDEF ve STOP'tur.
        const dash = 3.0;
        const gap = 7.0;

        double x = 0;

        while (x < size.width) {
          canvas.drawLine(
            Offset(x, y),
            Offset(math.min(x + dash, size.width), y),
            paint,
          );

          x += dash + gap;
        }
      }

      final occupiedLevelLabelTops = <double>[];

      void drawLevel({
        required double price,
        required Color color,
        required String label,
        bool dashed = false,
      }) {
        final y = py(price);

        final paint = Paint()
          ..color = color.withValues(alpha: .78)
          ..strokeWidth = 1.15;

        if (dashed) {
          const dash = 7.0;
          const gap = 5.0;

          double x = 0;

          while (x < size.width) {
            canvas.drawLine(
              Offset(x, y),
              Offset(math.min(x + dash, size.width), y),
              paint,
            );
            x += dash + gap;
          }
        } else {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: '$label ${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        const horizontalPadding = 7.0;
        const verticalPadding = 4.0;

        final boxWidth = textPainter.width + horizontalPadding * 2;
        final boxHeight = textPainter.height + verticalPadding * 2;

        final left = math.max(4.0, size.width - boxWidth - 5);

        var top = (y - boxHeight / 2)
            .clamp(chartTop, chartBottom - boxHeight)
            .toDouble();

        const minLabelGap = 4.0;
        for (final usedTop in occupiedLevelLabelTops) {
          final overlaps =
              top < usedTop + boxHeight + minLabelGap &&
              top + boxHeight + minLabelGap > usedTop;
          if (overlaps) {
            final below = usedTop + boxHeight + minLabelGap;
            final above = usedTop - boxHeight - minLabelGap;
            if (below <= chartBottom - boxHeight) {
              top = below;
            } else if (above >= chartTop) {
              top = above;
            }
          }
        }
        top = top.clamp(chartTop, chartBottom - boxHeight).toDouble();
        occupiedLevelLabelTops.add(top);

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top.toDouble(), boxWidth, boxHeight),
          const Radius.circular(6),
        );

        canvas.drawRRect(
          rect,
          Paint()..color = const Color(0xFF04100D).withValues(alpha: .94),
        );

        canvas.drawRRect(
          rect,
          Paint()
            ..color = color.withValues(alpha: .55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .8,
        );

        textPainter.paint(
          canvas,
          Offset(left + horizontalPadding, top + verticalPadding),
        );
      }

      // Alım / destek bölgesi:
      // S1 ile güncel fiyat arasında değil,
      // destek ile ATR kontrollü küçük tampon arasında.
      final rawBuyZoneLow = a.support + a.atr * .10;
      final rawBuyZoneHigh = math.min(
        a.resistance,
        a.support + math.max(a.atr * .55, 0.01),
      );
      final buyZoneLow = math.max(
        rawBuyZoneLow,
        a.stop + math.max(a.atr * .10, 0.01),
      );
      final buyZoneHigh = math.max(buyZoneLow, rawBuyZoneHigh);

      drawZone(
        low: buyZoneLow,
        high: buyZoneHigh,
        color: const Color(0xFF53D99A),
      );

      // Stop bölgesi
      drawZone(
        low: a.stop - math.max(a.atr * .12, 0.01),
        high: a.stop + math.max(a.atr * .12, 0.01),
        color: const Color(0xFFFF6673),
      );

      // İkincil referanslar: destek ve direnç.
      // Bunlar karar seviyesi değil, bağlam seviyesi olduğu için siliktir.
      drawReferenceLevel(price: a.support, color: const Color(0xFF53D99A));

      drawReferenceLevel(price: a.resistance, color: const Color(0xFFFFC857));

      drawLevel(
        price: a.stop,
        color: const Color(0xFFFF6673),
        label: 'STOP',
        dashed: true,
      );

      drawLevel(
        price: a.target,
        color: const Color(0xFFFFC857),
        label: 'HEDEF',
        dashed: true,
      );
    }

    for (var i = 0; i < renderData.length; i++) {
      final c = renderData[i], x = step * (i + 1), bull = c.close >= c.open;
      final color = bull ? const Color(0xFF43E694) : const Color(0xFFFF5D6B);
      canvas.drawLine(
        Offset(x, py(c.high)),
        Offset(x, py(c.low)),
        Paint()
          ..color = color
          ..strokeWidth = 1.1,
      );
      final y1 = py(c.open), y2 = py(c.close);
      final top = math.min(y1, y2), h = math.max(1.5, (y1 - y2).abs());
      canvas.drawRect(
        Rect.fromLTWH(x - bodyW / 2, top, bodyW, h),
        Paint()..color = color,
      );
      if (maxV > 0) {
        final vh = (c.volume / maxV) * 48;
        canvas.drawRect(
          Rect.fromLTWH(x - bodyW / 2, size.height - 8 - vh, bodyW, vh),
          Paint()..color = color.withValues(alpha: .5),
        );
      }
    }

    if (hoveredCandle != null) {
      var index = renderData.indexWhere((c) => c.time == hoveredCandle!.time);
      if (index < 0 && renderData.isNotEmpty) {
        var bestDistance = renderData.first.time
            .difference(hoveredCandle!.time)
            .abs();
        index = 0;
        for (var i = 1; i < renderData.length; i++) {
          final distance = renderData[i].time
              .difference(hoveredCandle!.time)
              .abs();
          if (distance < bestDistance) {
            bestDistance = distance;
            index = i;
          }
        }
      }
      if (index >= 0) {
        final x = step * (index + 1);
        final y = py(hoveredCandle!.close);
        final cross = Paint()
          ..color = const Color(0xFFB7C9C1).withValues(alpha: .55)
          ..strokeWidth = 1;
        canvas.drawLine(Offset(x, chartTop), Offset(x, chartBottom), cross);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), cross);
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = const Color(0xFF70F4AD),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TechnicalChartPainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.hoveredCandle != hoveredCandle;
}

class _RealMacdSeries {
  final List<double> macd;
  final List<double> signal;
  final List<double> histogram;

  const _RealMacdSeries({
    required this.macd,
    required this.signal,
    required this.histogram,
  });
}

class _RsiPainter extends CustomPainter {
  final List<double> values;

  const _RsiPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    const topPadding = 30.0;
    const bottomPadding = 12.0;

    final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);

    double py(double value) {
      final safe = value.clamp(0.0, 100.0);
      return topPadding + ((100.0 - safe) / 100.0) * chartHeight;
    }

    void drawGuide(double value, Color color) {
      final y = py(value);

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = color.withValues(alpha: .32)
          ..strokeWidth = 1,
      );
    }

    drawGuide(70, const Color(0xFFC474FF));
    drawGuide(50, const Color(0xFF789088));
    drawGuide(30, const Color(0xFFC474FF));

    if (values.length < 2) {
      return;
    }

    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : i / (values.length - 1) * size.width;

      final y = py(values[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC474FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RsiPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _MacdPainter extends CustomPainter {
  final _RealMacdSeries data;

  const _MacdPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.macd.isEmpty || data.signal.isEmpty || data.histogram.isEmpty) {
      return;
    }

    var maxAbs = 0.0;

    for (final value in [...data.macd, ...data.signal, ...data.histogram]) {
      maxAbs = math.max(maxAbs, value.abs());
    }

    if (maxAbs <= 0) {
      maxAbs = 1;
    }

    const topPadding = 30.0;
    const bottomPadding = 10.0;

    final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);

    final centerY = topPadding + chartHeight / 2;

    double py(double value) {
      final normalized = value / maxAbs;

      return centerY - normalized * (chartHeight * .44);
    }

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      Paint()
        ..color = const Color(0xFF789088).withValues(alpha: .28)
        ..strokeWidth = 1,
    );

    final count = math.min(
      data.macd.length,
      math.min(data.signal.length, data.histogram.length),
    );

    if (count <= 0) {
      return;
    }

    final step = count <= 1 ? size.width : size.width / (count - 1);

    final barWidth = math.max(1.5, math.min(5.0, step * .48));

    final macdPath = Path();
    final signalPath = Path();

    for (var i = 0; i < count; i++) {
      final x = count == 1 ? size.width / 2 : i / (count - 1) * size.width;

      final histogram = data.histogram[i];
      final histY = py(histogram);

      canvas.drawRect(
        Rect.fromLTRB(
          x - barWidth / 2,
          math.min(centerY, histY),
          x + barWidth / 2,
          math.max(centerY, histY),
        ),
        Paint()
          ..color = histogram >= 0
              ? const Color(0xFF4CE7CB)
              : const Color(0xFFFF6D68),
      );

      final macdY = py(data.macd[i]);
      final signalY = py(data.signal[i]);

      if (i == 0) {
        macdPath.moveTo(x, macdY);
        signalPath.moveTo(x, signalY);
      } else {
        macdPath.lineTo(x, macdY);
        signalPath.lineTo(x, signalY);
      }
    }

    canvas.drawPath(
      macdPath,
      Paint()
        ..color = const Color(0xFF3D9DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      signalPath,
      Paint()
        ..color = const Color(0xFFFF9E45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MacdPainter oldDelegate) {
    return oldDelegate.data.macd != data.macd ||
        oldDelegate.data.signal != data.signal ||
        oldDelegate.data.histogram != data.histogram;
  }
}

class _GhostLegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _GhostLegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .35), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFA4B5AD),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
      ],
    );
  }
}

enum _ReasonTone { positive, warning, negative, neutral }

_ReasonTone _reasonTone(String reason) {
  final text = reason.toLowerCase();

  const negativeWords = [
    'zayıf',
    'negatif',
    'altında',
    'bozul',
    'riskli',
    'yetersiz',
    'düşüş',
    'satış baskısı',
    'aşırı alım',
    'hacim zayıf',
    'momentum zayıf',
  ];

  const warningWords = [
    'karışık',
    'temkin',
    'dikkat',
    'nötr',
    'kontrollü',
    'bekle',
    'sınırlı',
    'yakın',
  ];

  const positiveWords = [
    'güçlü',
    'pozitif',
    'üzerinde',
    'yukarı',
    'destek',
    'alım',
    'olumlu',
    'momentum güçlü',
    'hacim güçlü',
    'risk/getiri güçlü',
    'risk-getiri güçlü',
  ];

  if (negativeWords.any(text.contains)) {
    return _ReasonTone.negative;
  }

  if (warningWords.any(text.contains)) {
    return _ReasonTone.warning;
  }

  if (positiveWords.any(text.contains)) {
    return _ReasonTone.positive;
  }

  return _ReasonTone.neutral;
}

Color _reasonColor(_ReasonTone tone) {
  switch (tone) {
    case _ReasonTone.positive:
      return const Color(0xFF70F4AD);
    case _ReasonTone.warning:
      return const Color(0xFFFFC857);
    case _ReasonTone.negative:
      return const Color(0xFFFF6673);
    case _ReasonTone.neutral:
      return const Color(0xFF8FA79D);
  }
}

IconData _reasonIcon(_ReasonTone tone) {
  switch (tone) {
    case _ReasonTone.positive:
      return Icons.check_circle_rounded;
    case _ReasonTone.warning:
      return Icons.warning_amber_rounded;
    case _ReasonTone.negative:
      return Icons.cancel_rounded;
    case _ReasonTone.neutral:
      return Icons.info_outline_rounded;
  }
}

class _CrocAnalysisFlow extends StatelessWidget {
  final List<_AnalysisStep> steps;
  final int visibleStep;
  final bool running;
  final String decision;
  final List<String> reasons;

  const _CrocAnalysisFlow({
    required this.steps,
    required this.visibleStep,
    required this.running,
    required this.decision,
    required this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    final shownCount = visibleStep.clamp(0, steps.length);

    if (shownCount == 0 && !running) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C4B39)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF70F4AD),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CROC ANALİZ AKIŞII',
                  style: TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (running)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF70F4AD),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          ...List.generate(shownCount, (index) {
            final step = steps[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _CrocAnalysisFlowRow(
                step: step,
                active: running && index == shownCount - 1,
              ),
            );
          }),

          if (!running && shownCount >= steps.length) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2118),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFF70F4AD).withValues(alpha: .32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CROC NEDEN BU KARARI VERDİ?',
                    style: TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    decision,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...reasons
                      .where((reason) => !reason.startsWith('Teknik merdiven:'))
                      .take(5)
                      .map((reason) {
                        final tone = _reasonTone(reason);
                        final toneColor = _reasonColor(tone);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Icon(
                                  _reasonIcon(tone),
                                  color: toneColor,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    color: tone == _ReasonTone.negative
                                        ? const Color(0xFFFFA0A8)
                                        : tone == _ReasonTone.warning
                                        ? const Color(0xFFFFD982)
                                        : const Color(0xFFB3C3BC),
                                    fontSize: 10.5,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CrocAnalysisFlowRow extends StatelessWidget {
  final _AnalysisStep step;
  final bool active;

  const _CrocAnalysisFlowRow({required this.step, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0C271C) : const Color(0xFF081A14),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: active
              ? const Color(0xFF70F4AD).withValues(alpha: .38)
              : const Color(0xFF173E30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF70F4AD).withValues(alpha: .08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(step.icon, size: 17, color: const Color(0xFF70F4AD)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.result,
                  style: const TextStyle(
                    color: Color(0xFF95A99F),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            active ? Icons.hourglass_top_rounded : Icons.check_rounded,
            color: active ? const Color(0xFFFFC857) : const Color(0xFF70F4AD),
            size: 17,
          ),
        ],
      ),
    );
  }
}

class _StockDetailBistIndexBadge extends StatelessWidget {
  final String symbol;

  const _StockDetailBistIndexBadge({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final code = symbol.toUpperCase();

    final String text;
    final Color color;

    if (BistIndexMembership.isBist30(code)) {
      text = 'B30';
      color = const Color(0xFFFFC857);
    } else if (BistIndexMembership.isBist50(code)) {
      text = 'B50';
      color = const Color(0xFF55C7F3);
    } else if (BistIndexMembership.isBist100(code)) {
      text = 'B100';
      color = const Color(0xFF70F4AD);
    } else {
      text = 'BIST';
      color = const Color(0xFF71877D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: .2,
        ),
      ),
    );
  }
}
