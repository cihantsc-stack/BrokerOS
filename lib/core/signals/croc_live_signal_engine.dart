import 'dart:math' as math;

import '../data_foundation/market/historical_candle.dart';

enum CrocLiveSignalType {
  seriousMoneyInflow,
  overbought,
  oversold,
  volumeExplosion,
}

class CrocLiveSignal {
  final CrocLiveSignalType type;
  final int score;
  final String title;
  final String action;
  final List<String> reasons;

  final double volumeRatio;
  final double priceChangePercent;
  final double vwap;
  final double rsi;
  final double stochasticK;
  final double bollingerUpper;
  final double bollingerLower;
  final double williamsR;
  final double chaikinMoneyFlow;

  const CrocLiveSignal({
    required this.type,
    required this.score,
    required this.title,
    required this.action,
    required this.reasons,
    required this.volumeRatio,
    required this.priceChangePercent,
    required this.vwap,
    required this.rsi,
    required this.stochasticK,
    required this.bollingerUpper,
    required this.bollingerLower,
    required this.williamsR,
    required this.chaikinMoneyFlow,
  });
}

class CrocLiveSignalEngine {
  const CrocLiveSignalEngine();

  List<CrocLiveSignal> analyze(List<HistoricalCandle> candles) {
    if (candles.length < 20) {
      return const [];
    }

    final closes = candles.map((e) => e.close).toList(growable: false);
    final last = candles.last;
    final price = last.close;

    final rsi = _rsi(closes, 14);
    final vwap = _vwap(candles);
    final stochasticK = _stochasticK(candles, 14);
    final bollinger = _bollinger(closes, 20, 2);
    final williamsR = _williamsR(candles, 14);
    final cmf = _chaikinMoneyFlow(candles, 20);
    final volumeRatio = _volumeRatio(candles, 20);

    final previousClose = candles.length >= 2
        ? candles[candles.length - 2].close
        : price;

    final priceChangePercent = previousClose == 0
        ? 0.0
        : ((price - previousClose) / previousClose) * 100;

    final signals = <CrocLiveSignal>[];

    // ============================================================
    // CİDDİ PARA GİRİŞİ
    // Olayı tespit eder. Doğrudan "AL" kararı değildir.
    // ============================================================

    var moneyScore = 0;
    final moneyReasons = <String>[];

    if (volumeRatio >= 2.0) {
      moneyScore += 25;
      moneyReasons.add(
        'Hacim normalin ${volumeRatio.toStringAsFixed(1)} katı.',
      );
    }

    if (volumeRatio >= 4.0) {
      moneyScore += 15;
    }

    if (volumeRatio >= 8.0) {
      moneyScore += 10;
    }

    if (price > vwap && vwap > 0) {
      moneyScore += 20;
      moneyReasons.add('Fiyat VWAP üzerinde.');
    }

    if (cmf > 0.05) {
      moneyScore += 20;
      moneyReasons.add('Chaikin para akışı pozitif.');
    }

    if (priceChangePercent > 0) {
      moneyScore += 10;
      moneyReasons.add(
        'Son mum fiyat hareketi +%${priceChangePercent.toStringAsFixed(2)}.',
      );
    }

    moneyScore = moneyScore.clamp(0, 100);

    if (moneyScore >= 60) {
      var action = 'İNCELE';

      // Çok hızlı yükselmiş fiyatın peşinden koşturma.
      if (rsi >= 75 || stochasticK >= 90 || price > bollinger.upper * 1.01) {
        action = 'KOVALAMA';
        moneyReasons.add('Fiyat kısa vadede fazla gerilmiş olabilir.');
      } else if (moneyScore >= 85) {
        action = 'GÜÇLÜ PARA GİRİŞİ';
      } else {
        action = 'PARA GİRİŞİ';
      }

      signals.add(
        CrocLiveSignal(
          type: CrocLiveSignalType.seriousMoneyInflow,
          score: moneyScore,
          title: 'CİDDİ PARA GİRİŞİ',
          action: action,
          reasons: moneyReasons,
          volumeRatio: volumeRatio,
          priceChangePercent: priceChangePercent,
          vwap: vwap,
          rsi: rsi,
          stochasticK: stochasticK,
          bollingerUpper: bollinger.upper,
          bollingerLower: bollinger.lower,
          williamsR: williamsR,
          chaikinMoneyFlow: cmf,
        ),
      );
    }

    // ============================================================
    // AŞIRI ALIM
    // ============================================================

    var overboughtScore = 0;
    final overboughtReasons = <String>[];

    if (rsi >= 70) {
      overboughtScore += 30;
      overboughtReasons.add('RSI ${rsi.toStringAsFixed(1)}.');
    }

    if (rsi >= 80) {
      overboughtScore += 10;
    }

    if (stochasticK >= 80) {
      overboughtScore += 20;
      overboughtReasons.add('Stochastic %K ${stochasticK.toStringAsFixed(1)}.');
    }

    if (stochasticK >= 95) {
      overboughtScore += 10;
    }

    if (price >= bollinger.upper) {
      overboughtScore += 20;
      overboughtReasons.add('Fiyat Bollinger üst bandında/üzerinde.');
    }

    if (williamsR >= -20) {
      overboughtScore += 20;
      overboughtReasons.add('Williams %R ${williamsR.toStringAsFixed(1)}.');
    }

    overboughtScore = overboughtScore.clamp(0, 100);

    if (overboughtScore >= 60) {
      signals.add(
        CrocLiveSignal(
          type: CrocLiveSignalType.overbought,
          score: overboughtScore,
          title: 'AŞIRI ALIM',
          action: overboughtScore >= 85 ? 'KOVALAMA' : 'DİKKAT',
          reasons: overboughtReasons,
          volumeRatio: volumeRatio,
          priceChangePercent: priceChangePercent,
          vwap: vwap,
          rsi: rsi,
          stochasticK: stochasticK,
          bollingerUpper: bollinger.upper,
          bollingerLower: bollinger.lower,
          williamsR: williamsR,
          chaikinMoneyFlow: cmf,
        ),
      );
    }

    signals.sort((a, b) => b.score.compareTo(a.score));

    return List<CrocLiveSignal>.unmodifiable(signals);
  }

  CrocLiveDiagnostic diagnose(List<HistoricalCandle> candles) {
    if (candles.length < 20) {
      throw ArgumentError('En az 20 mum gerekli.');
    }

    // Yahoo sonuna hacimsiz canli fiyat kaydi ekleyebiliyor.
    // Para radari hacim hesaplarinda son GERCEK hacimli mumu kullanir.
    final targetIndex = _lastValidVolumeIndex(candles);

    if (targetIndex < 1) {
      throw ArgumentError('Gecerli hacimli mum bulunamadi.');
    }

    final target = candles[targetIndex];

    final analysisCandles = candles.sublist(0, targetIndex + 1);
    final closes = analysisCandles.map((e) => e.close).toList(growable: false);

    final price = target.close;
    final previousClose = analysisCandles.length >= 2
        ? analysisCandles[analysisCandles.length - 2].close
        : price;

    final rsi = _rsi(closes, 14);
    final vwap = _vwap(analysisCandles);
    final stochasticK = _stochasticK(analysisCandles, 14);
    final bollinger = _bollinger(closes, 20, 2);
    final williamsR = _williamsR(analysisCandles, 14);
    final cmf = _chaikinMoneyFlow(analysisCandles, 20);

    // 5 dakika hacim anomalisi
    final volumeRatio = _volumeRatio(analysisCandles, 20);

    // Yaklasik 15 dakika hacim teyidi
    final volume15Ratio = _volume15Ratio(candles, targetIndex);

    // Son gercek 5dk mumun yaklasik TL hacmi
    final tlVolume = target.volume.toDouble() * price;

    // ========================================================
    // CROC PARA RADARI V3 - PARA HAFIZASI
    // V2 MONEY SCORE DEGISTIRILMEZ.
    // ========================================================

    final memory30 = _volumeMemory(candles, targetIndex, 30, 20);

    final memory60 = _volumeMemory(candles, targetIndex, 60, 20);

    final memory30MaxRatio = memory30.maxRatio;
    final memory60MaxRatio = memory60.maxRatio;

    final memory30MinutesAgo = memory30.minutesAgo;
    final memory60MinutesAgo = memory60.minutesAgo;

    final memory30PriceHold = memory30.priceHoldPercent;
    final memory60PriceHold = memory60.priceHoldPercent;

    // ========================================================
    // CROC PARA RADARI V3 - MEMORY SCORE V1
    // ========================================================

    final memoryScore = _memoryScore(
      memory30MaxRatio: memory30MaxRatio,
      memory60MaxRatio: memory60MaxRatio,
      memory30MinutesAgo: memory30MinutesAgo,
      memory60MinutesAgo: memory60MinutesAgo,
      memory30PriceHold: memory30PriceHold,
      memory60PriceHold: memory60PriceHold,
      cmf: cmf,
      price: price,
      vwap: vwap,
    );

    final priceChangePercent = previousClose == 0
        ? 0.0
        : ((price - previousClose) / previousClose) * 100;

    // ========================================================
    // CROC PARA RADARI V2
    // Hacim tek basina para girisi sayilmaz.
    // Hacim + 15dk teyit + TL buyukluk + CMF + VWAP + fiyat
    // birlikte degerlendirilir.
    // ========================================================

    var moneyScore = 0;

    // 5 DK HACIM ANOMALISI - maksimum 35
    if (volumeRatio >= 2.0) moneyScore += 15;
    if (volumeRatio >= 4.0) moneyScore += 10;
    if (volumeRatio >= 8.0) moneyScore += 10;

    // 15 DK HACIM TEYIDI - maksimum 15
    if (volume15Ratio >= 2.0) moneyScore += 8;
    if (volume15Ratio >= 4.0) moneyScore += 7;

    // TL HACIM FILTRESI - maksimum 10
    if (tlVolume >= 10 * 1000000) moneyScore += 5;
    if (tlVolume >= 50 * 1000000) moneyScore += 5;

    // PARA AKISI - maksimum 20
    if (cmf > 0.05) moneyScore += 10;
    if (cmf > 0.20) moneyScore += 10;

    // VWAP TEYIDI - maksimum 10
    if (price > vwap && vwap > 0) moneyScore += 10;

    // FIYAT TEYIDI - maksimum 10
    if (priceChangePercent > 0) moneyScore += 5;
    if (priceChangePercent >= 0.50) moneyScore += 5;

    moneyScore = moneyScore.clamp(0, 100);

    // ========================================================
    // ASIRI ALIM MOTORU - MEVCUT MANTIK KORUNDU
    // ========================================================

    var overboughtScore = 0;

    if (rsi >= 70) overboughtScore += 30;
    if (rsi >= 80) overboughtScore += 10;

    if (stochasticK >= 80) overboughtScore += 20;
    if (stochasticK >= 95) overboughtScore += 10;

    if (price >= bollinger.upper) overboughtScore += 20;

    if (williamsR >= -20) overboughtScore += 20;

    overboughtScore = overboughtScore.clamp(0, 100);

    return CrocLiveDiagnostic(
      price: price,
      moneyScore: moneyScore,
      overboughtScore: overboughtScore,
      volumeRatio: volumeRatio,
      volume15Ratio: volume15Ratio,
      tlVolume: tlVolume,
      memoryScore: memoryScore,
      memory30MaxRatio: memory30MaxRatio,
      memory60MaxRatio: memory60MaxRatio,
      memory30MinutesAgo: memory30MinutesAgo,
      memory60MinutesAgo: memory60MinutesAgo,
      memory30PriceHold: memory30PriceHold,
      memory60PriceHold: memory60PriceHold,
      priceChangePercent: priceChangePercent,
      vwap: vwap,
      rsi: rsi,
      stochasticK: stochasticK,
      williamsR: williamsR,
      chaikinMoneyFlow: cmf,
      bollingerUpper: bollinger.upper,
      bollingerLower: bollinger.lower,
    );
  }

  int _lastValidVolumeIndex(List<HistoricalCandle> candles) {
    for (var i = candles.length - 1; i >= 0; i--) {
      if (candles[i].volume > 0) {
        return i;
      }
    }

    return -1;
  }

  double _volume15Ratio(List<HistoricalCandle> candles, int targetIndex) {
    if (targetIndex < 2) return 0;

    // Hedef dahil son 3 gecerli mum.
    final current = <HistoricalCandle>[];

    for (var i = targetIndex; i >= 0 && current.length < 3; i--) {
      if (candles[i].volume > 0) {
        current.add(candles[i]);
      }
    }

    if (current.length < 3) return 0;

    // Mumlar arasinda buyuk zaman boslugu varsa farkli seanslari
    // ayni 15 dakikalik blok gibi kullanma.
    current.sort((a, b) => a.time.compareTo(b.time));

    for (var i = 1; i < current.length; i++) {
      final gap = current[i].time.difference(current[i - 1].time);

      if (gap.inMinutes > 10) {
        return 0;
      }
    }

    final currentVolume = current.fold<double>(
      0,
      (sum, candle) => sum + candle.volume.toDouble(),
    );

    final historicalBlocks = <double>[];

    var cursor = targetIndex - 3;

    while (cursor >= 2 && historicalBlocks.length < 20) {
      final block = <HistoricalCandle>[];

      for (var i = cursor; i >= 0 && block.length < 3; i--) {
        if (candles[i].volume > 0) {
          block.add(candles[i]);
        }
      }

      if (block.length == 3) {
        block.sort((a, b) => a.time.compareTo(b.time));

        var validTime = true;

        for (var i = 1; i < block.length; i++) {
          final gap = block[i].time.difference(block[i - 1].time);

          if (gap.inMinutes > 10) {
            validTime = false;
            break;
          }
        }

        if (validTime) {
          historicalBlocks.add(
            block.fold<double>(
              0,
              (sum, candle) => sum + candle.volume.toDouble(),
            ),
          );
        }
      }

      cursor -= 3;
    }

    if (historicalBlocks.isEmpty) return 0;

    final average =
        historicalBlocks.reduce((a, b) => a + b) / historicalBlocks.length;

    if (average <= 0) return 0;

    return currentVolume / average;
  }

  double _volumeRatio(List<HistoricalCandle> candles, int period) {
    if (candles.length < 2) return 1;

    // Yahoo bazen listenin sonuna canlı fiyat kaydı ekliyor.
    // Bu kaydın hacmi 0 olabildiği için son geçerli hacimli mumu kullan.
    var targetIndex = candles.length - 1;

    while (targetIndex >= 0 && candles[targetIndex].volume <= 0) {
      targetIndex--;
    }

    if (targetIndex <= 0) return 1;

    final targetVolume = candles[targetIndex].volume.toDouble();

    var total = 0.0;
    var count = 0;

    // Ölçülen mumdan önceki "period" adet geçerli hacimli mumu kullan.
    for (var i = targetIndex - 1; i >= 0 && count < period; i--) {
      final volume = candles[i].volume.toDouble();

      if (volume <= 0) {
        continue;
      }

      total += volume;
      count++;
    }

    if (count == 0) return 1;

    final average = total / count;

    if (average <= 0) return 1;

    return targetVolume / average;
  }

  int _memoryScore({
    required double memory30MaxRatio,
    required double memory60MaxRatio,
    required int memory30MinutesAgo,
    required int memory60MinutesAgo,
    required double memory30PriceHold,
    required double memory60PriceHold,
    required double cmf,
    required double price,
    required double vwap,
  }) {
    final score30 = _memoryWindowScore(
      ratio: memory30MaxRatio,
      minutesAgo: memory30MinutesAgo,
      priceHoldPercent: memory30PriceHold,
      maxAgeMinutes: 30,
    );

    final score60 = _memoryWindowScore(
      ratio: memory60MaxRatio,
      minutesAgo: memory60MinutesAgo,
      priceHoldPercent: memory60PriceHold,
      maxAgeMinutes: 60,
    );

    // En güçlü geçerli hafızayı temel al.
    var score = math.max(score30, score60);

    final bestPriceHold = score30 >= score60
        ? memory30PriceHold
        : memory60PriceHold;

    // ========================================================
    // PARA YÖNÜ - CMF
    // Hacim anomalisi satış hacmi de olabilir.
    // ========================================================

    if (cmf >= 0.20) {
      score += 12;
    } else if (cmf >= 0.05) {
      score += 7;
    } else if (cmf < -0.30) {
      score -= 25;
    } else if (cmf < -0.15) {
      score -= 18;
    } else if (cmf < -0.05) {
      score -= 10;
    }

    // ========================================================
    // VWAP KONUMU
    // ========================================================

    if (vwap > 0) {
      if (price > vwap) {
        score += 8;
      } else {
        score -= 12;
      }
    }

    // ========================================================
    // HAREKET KORUNUYOR MU?
    // Pozitif para akışı + fiyatın spike seviyesini koruması
    // güçlü teyit kabul edilir.
    // ========================================================

    if (cmf > 0.05 && bestPriceHold >= 100.0) {
      score += 8;
    }

    if (cmf > 0.20 && bestPriceHold >= 100.5) {
      score += 5;
    }

    // Para akışı negatifken fiyat da spike seviyesinin
    // altına düştüyse dağıtım/boşaltma ihtimalini cezalandır.
    if (cmf < -0.05 && bestPriceHold < 99.5) {
      score -= 10;
    }

    return score.round().clamp(0, 100);
  }

  double _memoryWindowScore({
    required double ratio,
    required int minutesAgo,
    required double priceHoldPercent,
    required int maxAgeMinutes,
  }) {
    if (ratio <= 0 || minutesAgo < 0 || priceHoldPercent <= 0) {
      return 0;
    }

    var score = 0.0;

    // ========================================================
    // HACİM ANOMALİSİ - maksimum 45
    // ========================================================

    if (ratio >= 2.0) score += 15;
    if (ratio >= 4.0) score += 10;
    if (ratio >= 8.0) score += 10;
    if (ratio >= 15.0) score += 10;

    // ========================================================
    // ZAMAN DECAY - maksimum 20
    //
    // V1 doğrusal decay kullanıyordu.
    // V2'de eski spike daha hızlı değer kaybeder.
    // ========================================================

    final ageRatio = (1.0 - (minutesAgo / maxAgeMinutes)).clamp(0.0, 1.0);

    final ageWeight = ageRatio * ageRatio;

    score += ageWeight * 20.0;

    // ========================================================
    // FİYAT KORUMASI
    // ========================================================

    if (priceHoldPercent >= 101.0) {
      score += 30;
    } else if (priceHoldPercent >= 100.0) {
      score += 25;
    } else if (priceHoldPercent >= 99.5) {
      score += 15;
    } else if (priceHoldPercent >= 99.0) {
      score += 7;
    } else if (priceHoldPercent >= 98.5) {
      score -= 3;
    } else {
      score -= 18;
    }

    return score.clamp(0.0, 85.0);
  }

  _VolumeMemoryResult _volumeMemory(
    List<HistoricalCandle> candles,
    int targetIndex,
    int lookbackMinutes,
    int referencePeriod,
  ) {
    if (targetIndex <= 0) {
      return const _VolumeMemoryResult.empty();
    }

    final target = candles[targetIndex];

    final windowStart = target.time.subtract(
      Duration(minutes: lookbackMinutes),
    );

    var bestRatio = 0.0;
    var bestIndex = -1;

    for (var i = targetIndex; i >= 0; i--) {
      final candle = candles[i];

      if (candle.time.isBefore(windowStart)) {
        break;
      }

      if (candle.volume <= 0) {
        continue;
      }

      var total = 0.0;
      var count = 0;

      for (var j = i - 1; j >= 0 && count < referencePeriod; j--) {
        final reference = candles[j];

        if (reference.volume <= 0) {
          continue;
        }

        final gap = candle.time.difference(reference.time);

        // Onceki seansi referans ortalamasina karistirma.
        if (gap.inHours >= 4) {
          break;
        }

        total += reference.volume.toDouble();
        count++;
      }

      if (count < 5) {
        continue;
      }

      final average = total / count;

      if (average <= 0) {
        continue;
      }

      final ratio = candle.volume.toDouble() / average;

      if (ratio > bestRatio) {
        bestRatio = ratio;
        bestIndex = i;
      }
    }

    if (bestIndex < 0) {
      return const _VolumeMemoryResult.empty();
    }

    final spike = candles[bestIndex];

    final minutesAgo = target.time.difference(spike.time).inMinutes;

    final priceHoldPercent = spike.close <= 0
        ? 0.0
        : (target.close / spike.close) * 100;

    return _VolumeMemoryResult(
      maxRatio: bestRatio,
      minutesAgo: minutesAgo,
      priceHoldPercent: priceHoldPercent,
    );
  }

  double _vwap(List<HistoricalCandle> candles) {
    var priceVolume = 0.0;
    var volume = 0.0;

    for (final candle in candles) {
      final v = candle.volume.toDouble();
      final typicalPrice = (candle.high + candle.low + candle.close) / 3;

      priceVolume += typicalPrice * v;
      volume += v;
    }

    if (volume <= 0) return candles.last.close;

    return priceVolume / volume;
  }

  double _stochasticK(List<HistoricalCandle> candles, int period) {
    final start = math.max(0, candles.length - period);
    final window = candles.sublist(start);

    final highest = window.map((e) => e.high).reduce(math.max);
    final lowest = window.map((e) => e.low).reduce(math.min);

    if (highest == lowest) return 50;

    return ((candles.last.close - lowest) / (highest - lowest)) * 100;
  }

  _BollingerResult _bollinger(
    List<double> closes,
    int period,
    double multiplier,
  ) {
    final start = math.max(0, closes.length - period);
    final window = closes.sublist(start);

    final mean = window.reduce((a, b) => a + b) / window.length;

    var variance = 0.0;

    for (final value in window) {
      variance += math.pow(value - mean, 2).toDouble();
    }

    variance /= window.length;

    final deviation = math.sqrt(variance);

    return _BollingerResult(
      middle: mean,
      upper: mean + deviation * multiplier,
      lower: mean - deviation * multiplier,
    );
  }

  double _williamsR(List<HistoricalCandle> candles, int period) {
    final start = math.max(0, candles.length - period);
    final window = candles.sublist(start);

    final highest = window.map((e) => e.high).reduce(math.max);
    final lowest = window.map((e) => e.low).reduce(math.min);

    if (highest == lowest) return -50;

    return -100 * ((highest - candles.last.close) / (highest - lowest));
  }

  double _chaikinMoneyFlow(List<HistoricalCandle> candles, int period) {
    final start = math.max(0, candles.length - period);
    final window = candles.sublist(start);

    var moneyFlowVolume = 0.0;
    var totalVolume = 0.0;

    for (final candle in window) {
      final range = candle.high - candle.low;
      final volume = candle.volume.toDouble();

      if (range <= 0) {
        totalVolume += volume;
        continue;
      }

      final multiplier =
          ((candle.close - candle.low) - (candle.high - candle.close)) / range;

      moneyFlowVolume += multiplier * volume;
      totalVolume += volume;
    }

    if (totalVolume <= 0) return 0;

    return moneyFlowVolume / totalVolume;
  }

  double _rsi(List<double> closes, int period) {
    if (closes.length <= period) return 50;

    var gains = 0.0;
    var losses = 0.0;

    for (var i = closes.length - period; i < closes.length; i++) {
      final difference = closes[i] - closes[i - 1];

      if (difference >= 0) {
        gains += difference;
      } else {
        losses -= difference;
      }
    }

    final averageGain = gains / period;
    final averageLoss = losses / period;

    if (averageLoss == 0) return 100;

    final rs = averageGain / averageLoss;

    return 100 - (100 / (1 + rs));
  }
}

class _VolumeMemoryResult {
  final double maxRatio;
  final int minutesAgo;
  final double priceHoldPercent;

  const _VolumeMemoryResult({
    required this.maxRatio,
    required this.minutesAgo,
    required this.priceHoldPercent,
  });

  const _VolumeMemoryResult.empty()
    : maxRatio = 0,
      minutesAgo = -1,
      priceHoldPercent = 0;
}

class _BollingerResult {
  final double middle;
  final double upper;
  final double lower;

  const _BollingerResult({
    required this.middle,
    required this.upper,
    required this.lower,
  });
}

class CrocLiveDiagnostic {
  final double price;
  final int moneyScore;
  final int overboughtScore;
  final double volumeRatio;
  final double volume15Ratio;
  final double tlVolume;

  // CROC Para Radari V3
  final int memoryScore;
  final double memory30MaxRatio;
  final double memory60MaxRatio;
  final int memory30MinutesAgo;
  final int memory60MinutesAgo;
  final double memory30PriceHold;
  final double memory60PriceHold;
  final double priceChangePercent;
  final double vwap;
  final double rsi;
  final double stochasticK;
  final double williamsR;
  final double chaikinMoneyFlow;
  final double bollingerUpper;
  final double bollingerLower;

  const CrocLiveDiagnostic({
    required this.price,
    required this.moneyScore,
    required this.overboughtScore,
    required this.volumeRatio,
    required this.volume15Ratio,
    required this.tlVolume,
    required this.memoryScore,
    required this.memory30MaxRatio,
    required this.memory60MaxRatio,
    required this.memory30MinutesAgo,
    required this.memory60MinutesAgo,
    required this.memory30PriceHold,
    required this.memory60PriceHold,
    required this.priceChangePercent,
    required this.vwap,
    required this.rsi,
    required this.stochasticK,
    required this.williamsR,
    required this.chaikinMoneyFlow,
    required this.bollingerUpper,
    required this.bollingerLower,
  });
}
