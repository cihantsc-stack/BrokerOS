import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/bist/database/bist100_master_database.dart';
import '../../../core/bist/models/bist_stock.dart';
import '../../../core/bist/services/croc_bist_tradable_universe.dart';
import '../../../core/bist/engine/sector_strength_engine.dart';
import '../../../core/bist/models/bist_stock_tick.dart';
import '../../../core/bist/models/sector_strength.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../../core/signals/croc_live_signal_engine.dart';
import '../models/crazy_money_candidate.dart';
import '../models/daily_trade_candidate.dart';
import 'global_pulse_service.dart';

class DailyTradeScannerService {
  DailyTradeScannerService._();

  static final DailyTradeScannerService instance = DailyTradeScannerService._();

  final YahooBistMarketDataSource _source = YahooBistMarketDataSource();
  final CrocLiveSignalEngine _liveSignalEngine = const CrocLiveSignalEngine();
  final CrocTechnicalAnalysisEngine _engine =
      const CrocTechnicalAnalysisEngine();

  final SectorStrengthEngine _sectorEngine = const SectorStrengthEngine();

  List<SectorStrength> _latestSectorStrengths = const [];

  List<SectorStrength> get latestSectorStrengths => _latestSectorStrengths;

  int _latestGlobalScore = 50;

  int get latestGlobalScore => _latestGlobalScore;

  List<CrazyMoneyCandidate> _latestCrazyMoneyCandidates = const [];

  List<CrazyMoneyCandidate> get latestCrazyMoneyCandidates =>
      _latestCrazyMoneyCandidates;

  List<DailyTradeCandidate>? _cache;
  DateTime? _cacheTime;

  Future<List<DailyTradeCandidate>>? _inFlightScan;

  Future<List<DailyTradeCandidate>> scan({
    bool forceRefresh = false,
    int concurrency = 15,
  }) {
    // Gecerli cache varsa tekrar tarama yapma.
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < const Duration(minutes: 5)) {
      return Future.value(_cache!);
    }

    // Ayni anda ikinci tam BIST taramasini baslatma.
    final running = _inFlightScan;
    if (running != null) {
      print('CROC SINGLE FLIGHT | DEVAM EDEN TARAMA PAYLASILDI');
      return running;
    }

    final future = _scanInternal(
      forceRefresh: forceRefresh,
      concurrency: concurrency,
    );

    _inFlightScan = future;

    future.whenComplete(() {
      if (identical(_inFlightScan, future)) {
        _inFlightScan = null;
      }
    });

    return future;
  }

  Future<List<DailyTradeCandidate>> _scanInternal({
    bool forceRefresh = false,
    int concurrency = 15,
  }) async {
    // CROC TIMING V3
    final scanWatch = Stopwatch()..start();
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

    // ========================================================
    // CROC DINAMIK BIST EVRENI
    //
    // KAP aktif şirket evreni -> Yahoo işlem görebilirlik
    // doğrulaması -> merkezi CROC tarama evreni.
    //
    // Eski BIST100 veritabanı yalnızca mevcut sektör
    // bilgisini tamamlamak için fallback olarak kullanılır.
    // ========================================================

    final tradableMembers = await CrocBistTradableUniverse().fetch();

    final knownSectors = <String, String>{
      for (final stock in Bist100MasterDatabase.stocks)
        stock.code.toUpperCase(): stock.sector,
    };

    final universe = tradableMembers
        .map(
          (member) => BistStock(
            code: member.code,
            name: member.title,
            sector: knownSectors[member.code.toUpperCase()] ?? 'Diğer',
          ),
        )
        .toList(growable: false);
    final results = <DailyTradeCandidate>[];
    final crazyMoneyResults = <CrazyMoneyCandidate>[];
    final crazyMoneyDiagnostics = <CrazyMoneyCandidate>[];
    final sectorTicks = <BistStockTick>[];

    for (var i = 0; i < universe.length; i += concurrency) {
      final batch = universe.skip(i).take(concurrency).toList();

      final batchWatch = Stopwatch()..start();

      final rows = await Future.wait(
        batch.map((stock) async {
          try {
            final dailyFuture = _source.fetch(
              stock.code,
              range: '1y',
              interval: '1d',
            );

            final Future<YahooBistSnapshot?> intradayFuture = _source
                .fetch(stock.code, range: '5d', interval: '5m')
                .then<YahooBistSnapshot?>(
                  (snapshot) => snapshot,
                  onError: (Object error, StackTrace stackTrace) => null,
                );

            final snapshot = await dailyFuture;

            if (snapshot.candles.length < 20) {
              try {
                await intradayFuture;
              } catch (_) {
                // Intraday istegi baslatildiysa hata Future uzerinde tutulmasin.
              }
              return null;
            }

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

            // CROC PARA RADARI V2 - INTRADAY
            CrocLiveDiagnostic? moneyDiagnostic;

            try {
              final intradaySnapshot = await intradayFuture;

              if (intradaySnapshot != null &&
                  intradaySnapshot.candles.length >= 20) {
                moneyDiagnostic = _liveSignalEngine.diagnose(
                  intradaySnapshot.candles,
                );
              }
            } catch (_) {
              // Intraday veri yoksa gunluk radar calismaya devam eder.
              moneyDiagnostic = null;
            }

            // ==================================================
            // CROC CRAZY MONEY - BAGIMSIZ PARA AKISI
            //
            // Normal teknik firsat filtresinden bagimsizdir.
            // Tum dinamik BIST evrenindeki guclu intraday
            // para hareketlerini ayri havuzda toplar.
            // ==================================================

            if (moneyDiagnostic != null) {
              final diagnostic = moneyDiagnostic;

              final crazyScore = _crazyMoneyScore(
                diagnostic: diagnostic,
                livePrice: livePrice,
                changePercent: snapshot.tick.changePercent,
              );

              crazyMoneyDiagnostics.add(
                CrazyMoneyCandidate(
                  symbol: stock.code,
                  company: stock.name,
                  sector: stock.sector,
                  livePrice: livePrice,
                  changePercent: snapshot.tick.changePercent,
                  crazyScore: crazyScore,
                  moneyScore: diagnostic.moneyScore,
                  memoryScore: diagnostic.memoryScore,
                  overboughtScore: diagnostic.overboughtScore,
                  volumeRatio: diagnostic.volumeRatio,
                  volume15Ratio: diagnostic.volume15Ratio,
                  tlVolume: diagnostic.tlVolume,
                  cmf: diagnostic.chaikinMoneyFlow,
                  vwap: diagnostic.vwap,
                  rsi: diagnostic.rsi,
                  memory30MaxRatio: diagnostic.memory30MaxRatio,
                  memory60MaxRatio: diagnostic.memory60MaxRatio,
                  memory30MinutesAgo: diagnostic.memory30MinutesAgo,
                  memory60MinutesAgo: diagnostic.memory60MinutesAgo,
                  memory30PriceHold: diagnostic.memory30PriceHold,
                  memory60PriceHold: diagnostic.memory60PriceHold,
                  reason: _crazyMoneyReason(
                    diagnostic: diagnostic,
                    livePrice: livePrice,
                  ),
                ),
              );
              // CROC SPECIAL MONEY DIAG V3
              // SADECE LOG - ESIKLERI VE KARAR MOTORUNU DEGISTIRMEZ.
              if (stock.code == 'LILAK' || stock.code == 'ALFAS') {
                final diagAboveVwap =
                    diagnostic.vwap > 0 && livePrice >= diagnostic.vwap;

                final diagVolumeConfirmed =
                    diagnostic.volumeRatio >= 1.35 ||
                    diagnostic.volume15Ratio >= 1.25;

                final diagEarlyGate =
                    crazyScore >= 60 &&
                    diagnostic.moneyScore >= 72 &&
                    diagnostic.memoryScore >= 65 &&
                    diagnostic.volumeRatio >= 2.0 &&
                    diagnostic.volume15Ratio >= 1.5 &&
                    diagnostic.chaikinMoneyFlow > 0 &&
                    diagAboveVwap &&
                    diagnostic.rsi < 82 &&
                    snapshot.tick.changePercent < 9.5;

                final diagNormalGate =
                    crazyScore >= 68 &&
                    diagnostic.moneyScore >= 58 &&
                    diagVolumeConfirmed;

                final diagReasons = <String>[];

                if (crazyScore < 60) {
                  diagReasons.add('EARLY Crazy<60');
                }

                if (diagnostic.moneyScore < 72) {
                  diagReasons.add('EARLY Para<72');
                }

                if (diagnostic.memoryScore < 65) {
                  diagReasons.add('EARLY Hafiza<65');
                }

                if (diagnostic.volumeRatio < 2.0) {
                  diagReasons.add('EARLY 5DK<2.0x');
                }

                if (diagnostic.volume15Ratio < 1.5) {
                  diagReasons.add('EARLY 15DK<1.5x');
                }

                if (diagnostic.chaikinMoneyFlow <= 0) {
                  diagReasons.add('EARLY CMF<=0');
                }

                if (!diagAboveVwap) {
                  diagReasons.add('EARLY VWAP ALTI');
                }

                if (diagnostic.rsi >= 82) {
                  diagReasons.add('EARLY RSI>=82');
                }

                if (snapshot.tick.changePercent >= 9.5) {
                  diagReasons.add('DEGISIM>=9.5');
                }

                if (crazyScore < 68) {
                  diagReasons.add('NORMAL Crazy<68');
                }

                if (diagnostic.moneyScore < 58) {
                  diagReasons.add('NORMAL Para<58');
                }

                if (!diagVolumeConfirmed) {
                  diagReasons.add('NORMAL Hacim teyidi yok');
                }

                // ignore: avoid_print
                print('');
                // ignore: avoid_print
                print('=== CROC SPECIAL MONEY DIAG | ${stock.code} ===');
                // ignore: avoid_print
                print(
                  'Crazy $crazyScore | '
                  'Para ${diagnostic.moneyScore} | '
                  'Hafiza ${diagnostic.memoryScore}',
                );
                // ignore: avoid_print
                print(
                  '5DK ${diagnostic.volumeRatio.toStringAsFixed(2)}x | '
                  '15DK ${diagnostic.volume15Ratio.toStringAsFixed(2)}x',
                );
                // ignore: avoid_print
                print(
                  'CMF ${diagnostic.chaikinMoneyFlow.toStringAsFixed(2)} | '
                  'VWAP ${diagnostic.vwap.toStringAsFixed(2)} | '
                  'FIYAT ${livePrice.toStringAsFixed(2)}',
                );
                // ignore: avoid_print
                print(
                  'VWAP ${diagAboveVwap ? "USTU" : "ALTI"} | '
                  'RSI ${diagnostic.rsi.toStringAsFixed(0)} | '
                  'DEGISIM %${snapshot.tick.changePercent.toStringAsFixed(2)}',
                );
                // ignore: avoid_print
                print('EARLY GATE  : ${diagEarlyGate ? "PASS" : "FAIL"}');
                // ignore: avoid_print
                print('NORMAL GATE : ${diagNormalGate ? "PASS" : "FAIL"}');
                // ignore: avoid_print
                print(
                  'NEDEN       : '
                  '${diagReasons.isEmpty ? "GATE UYGUN" : diagReasons.join(" | ")}',
                );
                // ignore: avoid_print
                print('================================================');
                // ignore: avoid_print
                print('');
              }

              if (_isCrazyMoneyCandidate(
                diagnostic: diagnostic,
                livePrice: livePrice,
                changePercent: snapshot.tick.changePercent,
                crazyScore: crazyScore,
              )) {
                crazyMoneyResults.add(
                  CrazyMoneyCandidate(
                    symbol: stock.code,
                    company: stock.name,
                    sector: stock.sector,
                    livePrice: livePrice,
                    changePercent: snapshot.tick.changePercent,
                    crazyScore: crazyScore,
                    moneyScore: diagnostic.moneyScore,
                    memoryScore: diagnostic.memoryScore,
                    overboughtScore: diagnostic.overboughtScore,
                    volumeRatio: diagnostic.volumeRatio,
                    volume15Ratio: diagnostic.volume15Ratio,
                    tlVolume: diagnostic.tlVolume,
                    cmf: diagnostic.chaikinMoneyFlow,
                    vwap: diagnostic.vwap,
                    rsi: diagnostic.rsi,
                    memory30MaxRatio: diagnostic.memory30MaxRatio,
                    memory60MaxRatio: diagnostic.memory60MaxRatio,
                    memory30MinutesAgo: diagnostic.memory30MinutesAgo,
                    memory60MinutesAgo: diagnostic.memory60MinutesAgo,
                    memory30PriceHold: diagnostic.memory30PriceHold,
                    memory60PriceHold: diagnostic.memory60PriceHold,
                    reason: _crazyMoneyReason(
                      diagnostic: diagnostic,
                      livePrice: livePrice,
                    ),
                  ),
                );
              }
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

            // ==================================================

            // CROC CRAZY MONEY PIPELINE

            //

            // Intraday Para Radari + Memory tum dinamik

            // evreni gorur. Teknik filtre bundan sonra

            // yalniz normal firsat listesini sinirlar.

            // ==================================================

            if (!_isTradeable(
              analysis: analysis,

              livePrice: livePrice,

              changePercent: snapshot.tick.changePercent,
            )) {
              return null;
            }

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
              moneyScore: moneyDiagnostic?.moneyScore ?? 0,
              memoryScore: moneyDiagnostic?.memoryScore ?? 0,
              overboughtScore: moneyDiagnostic?.overboughtScore ?? 0,
              moneyVolumeRatio: moneyDiagnostic?.volumeRatio ?? 0,
              moneyVolume15Ratio: moneyDiagnostic?.volume15Ratio ?? 0,
              moneyTlVolume: moneyDiagnostic?.tlVolume ?? 0,
              moneyCmf: moneyDiagnostic?.chaikinMoneyFlow ?? 0,
              moneyVwap: moneyDiagnostic?.vwap ?? 0,
              moneyRsi: moneyDiagnostic?.rsi ?? 0,
              moneyRadarAvailable: moneyDiagnostic != null,
            );
          } catch (_) {
            return null;
          }
        }),
      );

      results.addAll(rows.whereType<DailyTradeCandidate>());

      batchWatch.stop();

      print(
        'CROC TIMING V3 | BATCH ${(i ~/ concurrency) + 1} | '
        '${batch.length} HISSE | '
        '${(batchWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
      );
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
        moneyScore: candidate.moneyScore,
        overboughtScore: candidate.overboughtScore,
        moneyRadarAvailable: candidate.moneyRadarAvailable,
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

    crazyMoneyDiagnostics.sort((a, b) {
      final scoreCompare = b.crazyScore.compareTo(a.crazyScore);
      if (scoreCompare != 0) return scoreCompare;

      final moneyCompare = b.moneyScore.compareTo(a.moneyScore);
      if (moneyCompare != 0) return moneyCompare;

      return b.tlVolume.compareTo(a.tlVolume);
    });

    print('=== CROC CRAZY MONEY HAM TOP 5 ===');

    for (final item in crazyMoneyDiagnostics.take(5)) {
      print(
        '${item.symbol} | '
        'Crazy ${item.crazyScore} | '
        'Para ${item.moneyScore} | '
        'Hafiza ${item.memoryScore} | '
        'Hacim ${item.volumeRatio.toStringAsFixed(2)}x | '
        '15DK ${item.volume15Ratio.toStringAsFixed(2)}x | '
        'CMF ${item.cmf.toStringAsFixed(2)} | '
        'VWAP ${item.vwap.toStringAsFixed(2)} | '
        'FIYAT ${item.livePrice.toStringAsFixed(2)} | '
        'VWAP ${item.aboveVwap ? "USTU" : "ALTI"} | '
        'RSI ${item.rsi.toStringAsFixed(0)} | '
        'Degisim %${item.changePercent.toStringAsFixed(2)}',
      );
    }

    crazyMoneyResults.sort((a, b) {
      final scoreCompare = b.crazyScore.compareTo(a.crazyScore);
      if (scoreCompare != 0) return scoreCompare;

      final moneyCompare = b.moneyScore.compareTo(a.moneyScore);
      if (moneyCompare != 0) return moneyCompare;

      final memoryCompare = b.memoryScore.compareTo(a.memoryScore);
      if (memoryCompare != 0) return memoryCompare;

      return b.tlVolume.compareTo(a.tlVolume);
    });

    _latestCrazyMoneyCandidates = List<CrazyMoneyCandidate>.unmodifiable(
      crazyMoneyResults,
    );

    _cache = List.unmodifiable(contextualResults);
    _cacheTime = DateTime.now();

    scanWatch.stop();

    print('============================================================');
    print(
      'CROC TIMING V3 | TOTAL | '
      '${(scanWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN | '
      '${universe.length} HISSE',
    );
    print('============================================================');

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
    if (trend.contains('Yüks') || trend.contains('Yüks')) {
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
    if (trend.contains('Yüks') || trend.contains('Yüks')) {
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
    required int moneyScore,
    required int overboughtScore,
    required bool moneyRadarAvailable,
  }) {
    // Intraday Para Radari verisi yoksa eski skor sistemi korunur.
    if (!moneyRadarAvailable) {
      final weighted =
          (tradeScore * 0.70) + (sectorScore * 0.20) + (globalScore * 0.10);

      return weighted.round().clamp(0, 96);
    }

    // CROC PARA RADARI V2
    // Teknik kalite ana omurga olmaya devam eder.
    // Para Radari intraday para hareketini teyit eder.
    //
    // Teknik      : %55
    // Sektor      : %15
    // Global      : %10
    // Para Radari : %20
    var weighted =
        (tradeScore * 0.55) +
        (sectorScore * 0.15) +
        (globalScore * 0.10) +
        (moneyScore * 0.20);

    // Asiri alim freni.
    if (overboughtScore >= 95) {
      weighted -= 10;
    } else if (overboughtScore >= 80) {
      weighted -= 6;
    } else if (overboughtScore >= 60) {
      weighted -= 3;
    }

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

  int _crazyMoneyScore({
    required CrocLiveDiagnostic diagnostic,
    required double livePrice,
    required double changePercent,
  }) {
    var score = 0.0;

    // Ana para akisi %30
    score += diagnostic.moneyScore.clamp(0, 100) * 0.30;

    // Para hafizasi %25
    score += diagnostic.memoryScore.clamp(0, 100) * 0.25;

    // Anlik hacim %12
    final volumeScore = ((diagnostic.volumeRatio - 1.0) * 32).clamp(0, 100);
    score += volumeScore * 0.12;

    // 15 dk hacim teyidi %8
    final volume15Score = ((diagnostic.volume15Ratio - 1.0) * 35).clamp(0, 100);
    score += volume15Score * 0.08;

    // CMF %10
    final cmfScore = ((diagnostic.chaikinMoneyFlow + 0.10) * 250).clamp(0, 100);
    score += cmfScore * 0.10;

    // VWAP ustunde tutunma %7
    if (diagnostic.vwap > 0 && livePrice >= diagnostic.vwap) {
      score += 7;
    }

    // TL hacim %8
    if (diagnostic.tlVolume >= 1000000000) {
      score += 8;
    } else if (diagnostic.tlVolume >= 500000000) {
      score += 7;
    } else if (diagnostic.tlVolume >= 250000000) {
      score += 5;
    } else if (diagnostic.tlVolume >= 100000000) {
      score += 3;
    }

    // Asiri alim freni
    if (diagnostic.rsi >= 82) {
      score -= 18;
    } else if (diagnostic.rsi >= 78) {
      score -= 10;
    } else if (diagnostic.rsi >= 74) {
      score -= 4;
    }

    // Gunluk kosma freni
    if (changePercent >= 9.0) {
      score -= 18;
    } else if (changePercent >= 7.0) {
      score -= 10;
    } else if (changePercent >= 5.0) {
      score -= 4;
    }

    // VWAP alti ceza
    if (diagnostic.vwap > 0 && livePrice < diagnostic.vwap) {
      score -= 8;
    }

    return score.round().clamp(0, 100);
  }

  bool _isCrazyMoneyCandidate({
    required CrocLiveDiagnostic diagnostic,
    required double livePrice,
    required double changePercent,
    required int crazyScore,
  }) {
    if (livePrice <= 0) return false;

    final aboveVwap = diagnostic.vwap > 0 && livePrice >= diagnostic.vwap;

    final volumeConfirmed =
        diagnostic.volumeRatio >= 1.35 || diagnostic.volume15Ratio >= 1.25;

    // ========================================================
    // CROC EARLY MONEY GATE
    //
    // Normal Crazy Money kapisina henuz ulasmamis fakat
    // para + hafiza + hacim + CMF + VWAP birlikte cok guclu
    // olan erken para hareketlerini yakalar.
    // ========================================================

    final earlyMoneyGate =
        crazyScore >= 60 &&
        diagnostic.moneyScore >= 72 &&
        diagnostic.memoryScore >= 65 &&
        diagnostic.volumeRatio >= 2.0 &&
        diagnostic.volume15Ratio >= 1.5 &&
        diagnostic.chaikinMoneyFlow > 0 &&
        aboveVwap &&
        diagnostic.rsi < 82 &&
        changePercent < 9.5;

    // ========================================================
    // NORMAL CRAZY MONEY GATE
    // Mevcut ana kalite mantigi korunuyor.
    // ========================================================

    final normalMoneyGate =
        crazyScore >= 68 && diagnostic.moneyScore >= 58 && volumeConfirmed;

    // ========================================================
    // CROC EXTREME FLOW GATE
    // Olagan disi para/hacim hareketini erken gorunur yapar.
    // Bu tek basina AL sinyali degildir.
    // ========================================================

    final extremeFlowGate =
        crazyScore >= 55 &&
        diagnostic.moneyScore >= 50 &&
        diagnostic.memoryScore >= 70 &&
        diagnostic.chaikinMoneyFlow > 0 &&
        (diagnostic.volumeRatio >= 3.0 || diagnostic.volume15Ratio >= 3.0);

    if (!normalMoneyGate && !earlyMoneyGate && !extremeFlowGate) {
      return false;
    }

    // CMF negatif + VWAP alti birlikteyse her durumda RED.
    if (diagnostic.chaikinMoneyFlow < 0 && !aboveVwap) {
      return false;
    }

    // Fazla kosmus hareketi kovalamiyoruz.
    if (diagnostic.rsi >= 86) return false;
    if (changePercent >= 9.5) return false;

    // Hafiza zayifsa daha sert anlik teyit.
    if (diagnostic.memoryScore < 40 &&
        diagnostic.moneyScore < 72 &&
        diagnostic.volumeRatio < 1.8) {
      return false;
    }

    return true;
  }

  String _crazyMoneyReason({
    required CrocLiveDiagnostic diagnostic,
    required double livePrice,
  }) {
    final parts = <String>[];

    if (diagnostic.moneyScore >= 80) {
      parts.add('Çok güçlü para girişi');
    } else if (diagnostic.moneyScore >= 68) {
      parts.add('Güçlü para girişi');
    } else {
      parts.add('Para girişi hızlanıyor');
    }

    if (diagnostic.memoryScore >= 70) {
      parts.add('para hafızası güçlü');
    } else if (diagnostic.memoryScore >= 50) {
      parts.add('para hafızası teyitli');
    }

    if (diagnostic.volumeRatio >= 2.0) {
      parts.add('hacim patlaması');
    } else if (diagnostic.volumeRatio >= 1.5) {
      parts.add('hacim güçlü');
    }

    if (diagnostic.chaikinMoneyFlow > 0.10) {
      parts.add('CMF pozitif');
    }

    if (diagnostic.vwap > 0 && livePrice >= diagnostic.vwap) {
      parts.add('VWAP üstü');
    }

    return parts.join(' • ');
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
