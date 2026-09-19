import '../../../core/bist/services/croc_bist_tradable_universe.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../../core/signals/croc_live_signal_engine.dart';
import 'croc_fast_money_interpreter.dart';

/// CROC CRAZY MONEY FAST SCANNER V3
///
/// DailyTradeScanner'dan bagimsizdir.
/// Sadece 5d / 5m intraday veri kullanir.
///
/// MEVCUT ENGINE DEGISTIRILMEZ.
///
/// V3:
/// - MONEY = mevcut CrocLiveDiagnostic.moneyScore
/// - MEMORY = mevcut CrocLiveDiagnostic.memoryScore
/// - EARLY = Fast Scanner'a ait yeni erken hareket skoru
///
/// Siniflar:
/// EARLY  : para hareketi yeni olusuyor
/// ACTIVE : para hareketi su anda guclu
/// MEMORY : onceki hareket korunuyor
class CrazyMoneyFastScannerService {
  CrazyMoneyFastScannerService._();

  static final CrazyMoneyFastScannerService instance =
      CrazyMoneyFastScannerService._();

  final YahooBistMarketDataSource _source = YahooBistMarketDataSource();

  final CrocLiveSignalEngine _liveSignalEngine = const CrocLiveSignalEngine();

  final CrocFastMoneyInterpreter _interpreter =
      const CrocFastMoneyInterpreter();

  bool _running = false;

  bool get isRunning => _running;

  Future<void> scan({int concurrency = 20}) async {
    if (_running) {
      print('CROC FAST MONEY | SCAN ZATEN CALISIYOR');
      return;
    }

    _running = true;

    final watch = Stopwatch()..start();

    try {
      final universeWatch = Stopwatch()..start();

      final cachedMembers = CrocBistTradableUniverse.cached;

      final members = cachedMembers.isNotEmpty
          ? cachedMembers
          : await CrocBistTradableUniverse().fetch();

      print(
        'CROC FAST MONEY | UNIVERSE SOURCE | '
        '${cachedMembers.isNotEmpty ? "MEMORY CACHE" : "YAHOO VALIDATION"}',
      );

      universeWatch.stop();

      print(
        'CROC FAST MONEY | UNIVERSE | '
        '${members.length} HISSE | '
        '${(universeWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
      );

      var success = 0;
      var failed = 0;
      var candleReady = 0;
      var diagnosed = 0;

      final radarRows = <_FastMoneyRow>[];

      for (var i = 0; i < members.length; i += concurrency) {
        final batch = members.skip(i).take(concurrency).toList();
        final batchNumber = (i ~/ concurrency) + 1;

        final batchWatch = Stopwatch()..start();

        final rows = await Future.wait(
          batch.map((member) async {
            try {
              final snapshot = await _source.fetch(
                member.code,
                range: '5d',
                interval: '5m',
              );

              if (snapshot.candles.length < 20) {
                return _FastMoneyFetchResult(
                  candleCount: snapshot.candles.length,
                );
              }

              final diagnostic = _liveSignalEngine.diagnose(snapshot.candles);

              final price = diagnostic.price;

              final aboveVwap = diagnostic.vwap > 0 && price >= diagnostic.vwap;

              final earlyScore = _calculateEarlyScore(
                moneyScore: diagnostic.moneyScore,
                memoryScore: diagnostic.memoryScore,
                volumeRatio: diagnostic.volumeRatio,
                volume15Ratio: diagnostic.volume15Ratio,
                cmf: diagnostic.chaikinMoneyFlow,
                aboveVwap: aboveVwap,
                rsi: diagnostic.rsi,
                priceChangePercent: diagnostic.priceChangePercent,
              );

              final phase = _classifyPhase(
                earlyScore: earlyScore,
                moneyScore: diagnostic.moneyScore,
                memoryScore: diagnostic.memoryScore,
                volumeRatio: diagnostic.volumeRatio,
                volume15Ratio: diagnostic.volume15Ratio,
                cmf: diagnostic.chaikinMoneyFlow,
                aboveVwap: aboveVwap,
                rsi: diagnostic.rsi,
              );

              return _FastMoneyFetchResult(
                candleCount: snapshot.candles.length,
                row: _FastMoneyRow(
                  symbol: member.code,

                  // Diagnostic ile ayni gercek hacimli 5dk mum.
                  price: price,
                  changePercent: diagnostic.priceChangePercent,

                  moneyScore: diagnostic.moneyScore,
                  memoryScore: diagnostic.memoryScore,
                  earlyScore: earlyScore,

                  phase: phase,

                  volumeRatio: diagnostic.volumeRatio,
                  volume15Ratio: diagnostic.volume15Ratio,
                  cmf: diagnostic.chaikinMoneyFlow,
                  vwap: diagnostic.vwap,
                  rsi: diagnostic.rsi,
                  tlVolume: diagnostic.tlVolume,
                ),
              );
            } catch (_) {
              return const _FastMoneyFetchResult(candleCount: -1);
            }
          }),
        );

        for (final result in rows) {
          if (result.candleCount < 0) {
            failed++;
            continue;
          }

          success++;

          if (result.candleCount >= 20) {
            candleReady++;
          }

          if (result.row != null) {
            diagnosed++;
            radarRows.add(result.row!);
          }
        }

        batchWatch.stop();

        print(
          'CROC FAST MONEY | BATCH $batchNumber | '
          '${batch.length} HISSE | '
          '${(batchWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
        );
      }

      // ======================================================
      // V3 RADAR FILTRESI
      //
      // Tek basina hacim anomalisi listeye girmek icin yeterli
      // degildir. Pozitif para akisi / mevcut para skoru /
      // memory veya early teyidi gerekir.
      // ======================================================

      final interesting = radarRows.where((row) {
        final volumeWake = row.volumeRatio >= 1.50 || row.volume15Ratio >= 1.35;

        final directionalEvidence =
            row.cmf > 0.05 ||
            row.moneyScore >= 55 ||
            row.memoryScore >= 65 ||
            row.earlyScore >= 55;

        return volumeWake && directionalEvidence;
      }).toList();

      // ======================================================
      // SIRALAMA
      //
      // EARLY adaylari once gorulsun.
      // Sonra ACTIVE ve MEMORY.
      // NONE en alta.
      // ======================================================

      interesting.sort((a, b) {
        final phaseCompare = _phasePriority(
          b.phase,
        ).compareTo(_phasePriority(a.phase));

        if (phaseCompare != 0) {
          return phaseCompare;
        }

        final earlyCompare = b.earlyScore.compareTo(a.earlyScore);

        if (earlyCompare != 0) {
          return earlyCompare;
        }

        final moneyCompare = b.moneyScore.compareTo(a.moneyScore);

        if (moneyCompare != 0) {
          return moneyCompare;
        }

        return b.memoryScore.compareTo(a.memoryScore);
      });

      print('');
      print('============================================================');
      print('CROC FAST MONEY V3 RADAR');
      print('============================================================');

      if (interesting.isEmpty) {
        print('RADAR ADAYI YOK');
      } else {
        final limit = interesting.length > 40 ? 40 : interesting.length;

        for (var i = 0; i < limit; i++) {
          final row = interesting[i];

          final aboveVwap = row.vwap > 0 && row.price >= row.vwap;

          final interpretation = _interpreter.interpret(
            crazyScore: row.earlyScore,
            moneyScore: row.moneyScore,
            memoryScore: row.memoryScore,
            volumeRatio: row.volumeRatio,
            volume15Ratio: row.volume15Ratio,
            cmf: row.cmf,
            price: row.price,
            vwap: row.vwap,
            rsi: row.rsi,
            changePercent: row.changePercent,
          );

          print(
            '${(i + 1).toString().padLeft(2)} | '
            '${row.symbol.padRight(6)} | '
            '${interpretation.status.padRight(20)} | '
            'Guven ${interpretation.confidence.padRight(6)} | '
            '${interpretation.title}',
          );

          print('     CROC: ${interpretation.summary}');

          print(
            '     Teknik: '
            '${row.phase} | '
            'Early ${row.earlyScore} | '
            'Para ${row.moneyScore} | '
            'Hafiza ${row.memoryScore} | '
            '5DK ${row.volumeRatio.toStringAsFixed(2)}x | '
            '15DK ${row.volume15Ratio.toStringAsFixed(2)}x | '
            'CMF ${row.cmf.toStringAsFixed(2)} | '
            'VWAP ${aboveVwap ? "USTU" : "ALTI"} | '
            'RSI ${row.rsi.toStringAsFixed(0)}',
          );

          print('');
        }
      }

      final earlyCount = interesting
          .where((row) => row.phase == 'EARLY')
          .length;

      final activeCount = interesting
          .where((row) => row.phase == 'ACTIVE')
          .length;

      final memoryCount = interesting
          .where((row) => row.phase == 'MEMORY')
          .length;

      watch.stop();

      print('');
      print('============================================================');
      print('CROC FAST MONEY V3 COMPLETE');
      print('EVREN       : ${members.length}');
      print('BASARILI    : $success');
      print('HATA        : $failed');
      print('20+ MUM     : $candleReady');
      print('DIAGNOSTIC  : $diagnosed');
      print('RADAR ADAYI : ${interesting.length}');
      print('EARLY       : $earlyCount');
      print('ACTIVE      : $activeCount');
      print('MEMORY      : $memoryCount');
      print(
        'TOPLAM SURE : '
        '${(watch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
      );
      print('============================================================');
    } finally {
      _running = false;
    }
  }

  // ==========================================================
  // CROC FAST MONEY V3 - EARLY SCORE V1
  //
  // Amac:
  // "Hacim patladiktan sonra" degil,
  // hareket gelisirken yakalamak.
  //
  // Mevcut MoneyScore ve MemoryScore DEGISTIRILMEZ.
  // ==========================================================

  static int _calculateEarlyScore({
    required int moneyScore,
    required int memoryScore,
    required double volumeRatio,
    required double volume15Ratio,
    required double cmf,
    required bool aboveVwap,
    required double rsi,
    required double priceChangePercent,
  }) {
    var score = 0;

    // --------------------------------------------------------
    // 5DK HACIM UYANISI - max 20
    // --------------------------------------------------------

    if (volumeRatio >= 1.20) score += 6;
    if (volumeRatio >= 1.50) score += 6;
    if (volumeRatio >= 2.00) score += 4;
    if (volumeRatio >= 3.00) score += 4;

    // --------------------------------------------------------
    // 15DK DEVAMLILIK - max 20
    // --------------------------------------------------------

    if (volume15Ratio >= 1.10) score += 6;
    if (volume15Ratio >= 1.35) score += 6;
    if (volume15Ratio >= 1.75) score += 4;
    if (volume15Ratio >= 2.50) score += 4;

    // --------------------------------------------------------
    // PARA AKISI - max 20
    // --------------------------------------------------------

    if (cmf > 0.00) score += 5;
    if (cmf > 0.05) score += 5;
    if (cmf > 0.15) score += 5;
    if (cmf > 0.25) score += 5;

    // --------------------------------------------------------
    // VWAP - max 15
    // --------------------------------------------------------

    if (aboveVwap) {
      score += 15;
    }

    // --------------------------------------------------------
    // FIYAT HENUZ KACMAMIS MI? - max 15
    //
    // Erken radar icin +%0 ile +%2 arasi daha degerli.
    // --------------------------------------------------------

    if (priceChangePercent >= -0.25 && priceChangePercent <= 2.00) {
      score += 10;
    }

    if (priceChangePercent >= 0 && priceChangePercent <= 1.00) {
      score += 5;
    }

    // --------------------------------------------------------
    // RSI GERILIM KONTROLU - max 10
    // --------------------------------------------------------

    if (rsi >= 40 && rsi < 70) {
      score += 10;
    } else if (rsi >= 30 && rsi < 75) {
      score += 5;
    }

    // --------------------------------------------------------
    // HAREKET ZATEN OLGUNLASMISSA EARLY CEZASI
    // --------------------------------------------------------

    if (rsi >= 78) {
      score -= 15;
    }

    if (priceChangePercent >= 4.0) {
      score -= 15;
    }

    if (priceChangePercent >= 7.0) {
      score -= 15;
    }

    // Memory cok yuksekse olay yeni olmayabilir.
    if (memoryScore >= 85) {
      score -= 10;
    }

    // Money zaten cok yuksekse ACTIVE fazina gecmis olabilir.
    if (moneyScore >= 75) {
      score -= 5;
    }

    return score.clamp(0, 100);
  }

  // ==========================================================
  // FAZ SINIFLANDIRMASI
  // ==========================================================

  static String _classifyPhase({
    required int earlyScore,
    required int moneyScore,
    required int memoryScore,
    required double volumeRatio,
    required double volume15Ratio,
    required double cmf,
    required bool aboveVwap,
    required double rsi,
  }) {
    // EARLY:
    // Hacim uyanmis + pozitif akis + fiyat teyidi,
    // fakat hareket henuz asiri gerilmemis.
    final early =
        earlyScore >= 60 &&
        cmf > 0.05 &&
        (volumeRatio >= 1.50 || volume15Ratio >= 1.35) &&
        aboveVwap &&
        rsi < 78;

    if (early) {
      return 'EARLY';
    }

    // ACTIVE:
    // Mevcut para motoru artik guclu para hareketi goruyor.
    final active =
        moneyScore >= 55 &&
        cmf > 0 &&
        (volumeRatio >= 1.50 || volume15Ratio >= 1.35);

    if (active) {
      return 'ACTIVE';
    }

    // MEMORY:
    // Onceki hacim olayi halen korunuyor.
    final memory =
        memoryScore >= 65 &&
        cmf >= 0 &&
        (volumeRatio >= 1.20 || volume15Ratio >= 1.20);

    if (memory) {
      return 'MEMORY';
    }

    return 'WATCH';
  }

  static int _phasePriority(String phase) {
    switch (phase) {
      case 'EARLY':
        return 4;

      case 'ACTIVE':
        return 3;

      case 'MEMORY':
        return 2;

      case 'WATCH':
        return 1;

      default:
        return 0;
    }
  }
}

class _FastMoneyFetchResult {
  final int candleCount;
  final _FastMoneyRow? row;

  const _FastMoneyFetchResult({required this.candleCount, this.row});
}

class _FastMoneyRow {
  final String symbol;
  final double price;
  final double changePercent;

  final int moneyScore;
  final int memoryScore;
  final int earlyScore;

  final String phase;

  final double volumeRatio;
  final double volume15Ratio;
  final double cmf;
  final double vwap;
  final double rsi;
  final double tlVolume;

  const _FastMoneyRow({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.moneyScore,
    required this.memoryScore,
    required this.earlyScore,
    required this.phase,
    required this.volumeRatio,
    required this.volume15Ratio,
    required this.cmf,
    required this.vwap,
    required this.rsi,
    required this.tlVolume,
  });
}
