import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/bist/database/bist100_master_database.dart';
import '../../../core/bist/engine/sector_strength_engine.dart';
import '../../../core/bist/models/bist_stock_tick.dart';
import '../../../core/bist/models/sector_strength.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../models/daily_trade_candidate.dart';
import 'global_pulse_service.dart';

class DailyTradeScannerService {
  DailyTradeScannerService._();

  static final DailyTradeScannerService instance = DailyTradeScannerService._();

  final YahooBistMarketDataSource _source = YahooBistMarketDataSource();
  final CrocTechnicalAnalysisEngine _engine =
      const CrocTechnicalAnalysisEngine();

  final SectorStrengthEngine _sectorEngine = const SectorStrengthEngine();

  List<SectorStrength> _latestSectorStrengths = const [];

  List<SectorStrength> get latestSectorStrengths => _latestSectorStrengths;

  int _latestGlobalScore = 50;

  int get latestGlobalScore => _latestGlobalScore;

  List<DailyTradeCandidate>? _cache;
  DateTime? _cacheTime;

  Future<List<DailyTradeCandidate>> scan({
    bool forceRefresh = false,
    int concurrency = 10,
  }) async {
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < const Duration(minutes: 5)) {
      return _cache!;
    }

    try {
      final globalPulse = await GlobalPulseService.instance.fetch(
        forceRefresh: forceRefresh,
      );
      _latestGlobalScore = globalPulse.score;
    } catch (_) {
      _latestGlobalScore = 50;
    }

    final universe = Bist100MasterDatabase.stocks;
    final results = <DailyTradeCandidate>[];
    final sectorTicks = <BistStockTick>[];

    for (var i = 0; i < universe.length; i += concurrency) {
      final batch = universe.skip(i).take(concurrency).toList();

      final rows = await Future.wait(
        batch.map((stock) async {
          try {
            final snapshot = await _source.fetch(
              stock.code,
              range: '1y',
              interval: '1d',
            );

            if (snapshot.candles.length < 20) return null;

            final analysis = _engine.analyze(snapshot.candles);
            final livePrice = snapshot.tick.price;

            sectorTicks.add(
              BistStockTick(
                stock: stock,
                price: livePrice,
                changePercent: snapshot.tick.changePercent,
                volume: snapshot.tick.volume,
              ),
            );

            if (!_isTradeable(
              analysis: analysis,
              livePrice: livePrice,
              changePercent: snapshot.tick.changePercent,
            )) {
              return null;
            }

            final rawTradeScore = _tradeScore(
              analysis: analysis,
              livePrice: livePrice,
            );

            final dataQualityPenalty = snapshot.dataQualityScore >= 95
                ? 0
                : snapshot.dataQualityScore >= 80
                ? 5
                : snapshot.dataQualityScore >= 60
                ? 12
                : 20;

            final tradeScore = (rawTradeScore - dataQualityPenalty).clamp(
              0,
              96,
            );
            final baseTradeReason = _tradeReason(
              analysis: analysis,
              livePrice: livePrice,
            );

            final tradeReason = snapshot.dataQualityScore < 95
                ? '$baseTradeReason • Veri güveni ${snapshot.dataQualityScore}/100'
                : baseTradeReason;

            return DailyTradeCandidate(
              symbol: stock.code,
              company: stock.name,
              sector: stock.sector,
              livePrice: livePrice,
              changePercent: snapshot.tick.changePercent,
              analysis: analysis,
              tradeScore: tradeScore,
              sectorScore: 50,
              globalScore: _latestGlobalScore,
              crocScore: tradeScore,
              tradeReason: tradeReason,
              contextLabel: 'Bağlam hesaplanıyor',
            );
          } catch (_) {
            return null;
          }
        }),
      );

      results.addAll(rows.whereType<DailyTradeCandidate>());
    }

    _latestSectorStrengths = sectorTicks.isEmpty
        ? const <SectorStrength>[]
        : _sectorEngine.calculate(sectorTicks);

    final sectorScoreMap = <String, int>{
      for (final item in _latestSectorStrengths) item.sector: item.score,
    };

    final contextualResults = results.map((candidate) {
      final sectorScore = sectorScoreMap[candidate.sector] ?? 50;
      final globalScore = _latestGlobalScore;

      final crocScore = _crocContextScore(
        tradeScore: candidate.tradeScore,
        sectorScore: sectorScore,
        globalScore: globalScore,
      );

      return candidate.copyWith(
        sectorScore: sectorScore,
        globalScore: globalScore,
        crocScore: crocScore,
        contextLabel: _contextLabel(
          tradeScore: candidate.tradeScore,
          sectorScore: sectorScore,
          globalScore: globalScore,
          crocScore: crocScore,
        ),
      );
    }).toList();

    contextualResults.sort(_compareCandidates);

    _cache = List.unmodifiable(contextualResults);
    _cacheTime = DateTime.now();

    return _cache!;
  }

  bool _isTradeable({
    required CrocTechnicalAnalysis analysis,
    required double livePrice,
    required double changePercent,
  }) {
    if (livePrice <= 0) return false;
    if (analysis.score < 66) return false;
    if (analysis.riskReward < 1.0) return false;
    if (analysis.stop <= 0 || analysis.stop >= livePrice) return false;
    if (analysis.support <= 0) return false;
    if (analysis.resistance <= livePrice) return false;

    final stopRisk = ((livePrice - analysis.stop) / livePrice) * 100;
    if (stopRisk > 6.6) return false;

    // CROC güvenlik frenleriyle uyumlu ek süzgeç.
    if (analysis.rsi > 78) return false;

    // SIMDI GIRILIR MI? filtresi.
    if (changePercent >= 8.0) return false;

    final idealEntryHigh = analysis.support + (analysis.atr * 0.55);
    if (idealEntryHigh > 0 && livePrice > idealEntryHigh * 1.025) {
      return false;
    }

    final remainingUpsidePercent =
        ((analysis.target - livePrice) / livePrice) * 100;
    if (remainingUpsidePercent < 2.5) return false;

    final currentRisk = livePrice - analysis.stop;
    final currentReward = analysis.target - livePrice;
    if (currentRisk <= 0 || currentReward <= 0) return false;

    final currentRiskReward = currentReward / currentRisk;
    if (currentRiskReward < 1.25) return false;

    return true;
  }

  int _tradeScore({
    required CrocTechnicalAnalysis analysis,
    required double livePrice,
  }) {
    var score = 0.0;

    score += (analysis.score.clamp(0, 100) / 100) * 45;

    if (analysis.riskReward >= 2.5) {
      score += 18;
    } else if (analysis.riskReward >= 2.0) {
      score += 16;
    } else if (analysis.riskReward >= 1.6) {
      score += 13;
    } else if (analysis.riskReward >= 1.3) {
      score += 10;
    } else {
      score += 6;
    }

    if (analysis.volumeRatio >= 1.8) {
      score += 12;
    } else if (analysis.volumeRatio >= 1.4) {
      score += 10;
    } else if (analysis.volumeRatio >= 1.15) {
      score += 8;
    } else if (analysis.volumeRatio >= 0.90) {
      score += 5;
    } else {
      score += 2;
    }

    final trend = analysis.trend;
    if (trend.contains('Yüks') || trend.contains('YÃ¼ks')) {
      score += 10;
    } else if (trend.contains('Yatay')) {
      score += 4;
    }

    final supportDistance = livePrice <= 0
        ? 99.0
        : ((livePrice - analysis.support) / livePrice) * 100;

    if (supportDistance >= 1 && supportDistance <= 3) {
      score += 8;
    } else if (supportDistance <= 5) {
      score += 6;
    } else if (supportDistance <= 8) {
      score += 3;
    }

    final stopRisk = livePrice <= 0
        ? 99.0
        : ((livePrice - analysis.stop) / livePrice) * 100;

    if (stopRisk >= 1.8 && stopRisk <= 3.2) {
      score += 7;
    } else if (stopRisk <= 4.5) {
      score += 5;
    } else if (stopRisk <= 6.5) {
      score += 2;
    }

    if (analysis.rsi > 75) {
      score -= 10;
    } else if (analysis.rsi > 70) {
      score -= 5;
    }

    if (analysis.volumeRatio < 0.70) score -= 6;

    return score.round().clamp(0, 96);
  }

  String _tradeReason({
    required CrocTechnicalAnalysis analysis,
    required double livePrice,
  }) {
    final reasons = <String>[];

    final trend = analysis.trend;
    if (trend.contains('Yüks') || trend.contains('YÃ¼ks')) {
      reasons.add('Trend güçlü');
    }

    if (analysis.volumeRatio >= 1.20) {
      reasons.add('Hacim ${analysis.volumeRatio.toStringAsFixed(1)}x');
    }

    if (analysis.riskReward >= 1.8) {
      reasons.add('R/G ${analysis.riskReward.toStringAsFixed(1)}');
    }

    final supportDistance = livePrice <= 0
        ? 99.0
        : ((livePrice - analysis.support) / livePrice) * 100;

    if (supportDistance >= 1 && supportDistance <= 5) {
      reasons.add('Desteğe yakın');
    }

    if (analysis.rsi >= 50 && analysis.rsi <= 68) {
      reasons.add('RSI dengeli');
    }

    if (analysis.macd > analysis.macdSignal && analysis.macdHistogram > 0) {
      reasons.add('MACD +');
    }

    return reasons.isEmpty
        ? 'CROC filtresini geçti'
        : reasons.take(3).join(' • ');
  }

  int _crocContextScore({
    required int tradeScore,
    required int sectorScore,
    required int globalScore,
  }) {
    // Hissenin kendi kalitesi ana ağırlık.
    // Sektör teyit eder, global ortam agresifliği ayarlar.
    final weighted =
        (tradeScore * 0.70) + (sectorScore * 0.20) + (globalScore * 0.10);

    return weighted.round().clamp(0, 96);
  }

  String _contextLabel({
    required int tradeScore,
    required int sectorScore,
    required int globalScore,
    required int crocScore,
  }) {
    if (globalScore <= 30 && crocScore >= 78) {
      return 'Güçlü hisse • Global risk yüksek';
    }

    if (sectorScore >= 80 && crocScore >= 82) {
      return 'Sektör destekli güçlü fırsat';
    }

    if (globalScore >= 65 && sectorScore >= 70 && crocScore >= 82) {
      return 'Piyasa koşulları destekliyor';
    }

    if (tradeScore >= 85 && crocScore < tradeScore - 5) {
      return 'Teknik güçlü • Bağlam temkinli';
    }

    if (crocScore >= 82) {
      return 'CROC güçlü aday';
    }

    if (crocScore >= 75) {
      return 'Seçici trade adayı';
    }

    return 'Temkinli izleme';
  }

  int _compareCandidates(DailyTradeCandidate a, DailyTradeCandidate b) {
    final crocCompare = b.crocScore.compareTo(a.crocScore);
    if (crocCompare != 0) return crocCompare;

    final scoreCompare = b.tradeScore.compareTo(a.tradeScore);
    if (scoreCompare != 0) return scoreCompare;

    final technicalCompare = b.technicalScore.compareTo(a.technicalScore);
    if (technicalCompare != 0) return technicalCompare;

    final rrCompare = b.riskReward.compareTo(a.riskReward);
    if (rrCompare != 0) return rrCompare;

    return b.volumeRatio.compareTo(a.volumeRatio);
  }

  void clearCache() {
    _cache = null;
    _cacheTime = null;
  }
}
