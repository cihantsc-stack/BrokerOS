import 'dart:math' as math;

import '../data_foundation/market/historical_candle.dart';

class CrocTechnicalAnalysis {
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHistogram;

  final double ema20;
  final double ema50;
  final double? ema200;

  final double support;
  final double support2;
  final double support3;

  final double resistance;
  final double resistance2;
  final double resistance3;

  final double stop;

  final double target;
  final double target2;
  final double target3;

  final double atr;
  final double volumeRatio;
  final double riskReward;

  final int score;

  final String decision;
  final String trend;
  final String risk;

  final List<String> reasons;

  const CrocTechnicalAnalysis({
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.ema20,
    required this.ema50,
    required this.ema200,
    required this.support,
    required this.support2,
    required this.support3,
    required this.resistance,
    required this.resistance2,
    required this.resistance3,
    required this.stop,
    required this.target,
    required this.target2,
    required this.target3,
    required this.atr,
    required this.volumeRatio,
    required this.riskReward,
    required this.score,
    required this.decision,
    required this.trend,
    required this.risk,
    required this.reasons,
  });
}

class CrocTechnicalAnalysisEngine {
  const CrocTechnicalAnalysisEngine();

  CrocTechnicalAnalysis analyze(List<HistoricalCandle> candles) {
    if (candles.length < 20) {
      throw StateError('Teknik analiz için en az 20 mum gerekli.');
    }

    final closes = candles.map((e) => e.close).toList(growable: false);

    final last = candles.last;
    final price = last.close;

    final rsi = _rsi(closes, 14);

    final ema20 = _ema(closes, math.min(20, closes.length));

    final ema50 = _ema(closes, math.min(50, closes.length));

    final ema200 = closes.length >= 200 ? _ema(closes, 200) : null;

    final macdLine = _ema(closes, 12) - _ema(closes, 26);

    final macdSeries = _macdSeries(closes);

    final signal = _ema(macdSeries, math.min(9, macdSeries.length));

    final histogram = macdLine - signal;

    final atr = _atr(candles, 14);

    final atrRatio = price <= 0 ? 0.0 : atr / price;

    final lookback20 = candles.length >= 20
        ? candles.sublist(candles.length - 20)
        : candles;

    // ============================================================
    // CROC AI YAKIN DESTEK / DİRENÇ MOTORU
    // ============================================================
    // Mutlak 20/40/60 günlük dip-tepe yerine, son 120 gündeki
    // güncel fiyata yakın yerel swing seviyeleri kullanılır.

    final levelLookback = candles.length >= 120
        ? candles.sublist(candles.length - 120)
        : candles;

    final supportCandidates = <double>[];
    final resistanceCandidates = <double>[];

    for (var i = 2; i < levelLookback.length - 2; i++) {
      final candle = levelLookback[i];

      final isSwingLow =
          candle.low <= levelLookback[i - 1].low &&
          candle.low <= levelLookback[i - 2].low &&
          candle.low <= levelLookback[i + 1].low &&
          candle.low <= levelLookback[i + 2].low;

      final isSwingHigh =
          candle.high >= levelLookback[i - 1].high &&
          candle.high >= levelLookback[i - 2].high &&
          candle.high >= levelLookback[i + 1].high &&
          candle.high >= levelLookback[i + 2].high;

      if (isSwingLow && candle.low < price) {
        final distance = (price - candle.low) / price;
        if (distance <= 0.18) supportCandidates.add(candle.low);
      }

      if (isSwingHigh && candle.high > price) {
        final distance = (candle.high - price) / price;
        if (distance <= 0.25) resistanceCandidates.add(candle.high);
      }
    }

    List<double> uniqueLevels(List<double> values, {required bool descending}) {
      final sorted = [...values]..sort();
      if (descending) sorted.sort((a, b) => b.compareTo(a));

      final result = <double>[];
      final mergeDistance = math.max(atr * 0.35, price * 0.006);

      for (final value in sorted) {
        if (result.every((x) => (x - value).abs() > mergeDistance)) {
          result.add(value);
        }
      }
      return result;
    }

    final supports = uniqueLevels(supportCandidates, descending: true);
    final resistances = uniqueLevels(resistanceCandidates, descending: false);

    double supportAt(int index, double multiplier) {
      if (supports.length > index) return supports[index];
      final previous = index == 0
          ? price
          : supportAt(index - 1, multiplier - 0.35);
      return math
          .max(0.01, previous - math.max(atr * multiplier, price * 0.018))
          .toDouble();
    }

    double resistanceAt(int index, double multiplier) {
      if (resistances.length > index) return resistances[index];
      final previous = index == 0
          ? price
          : resistanceAt(index - 1, multiplier - 0.35);
      return previous + math.max(atr * multiplier, price * 0.022);
    }

    final minimumLevelGap = math.max(price * 0.006, atr * 0.20);

    final support = supportAt(0, 1.15);
    final support2 = math
        .min(supportAt(1, 1.50), support - minimumLevelGap)
        .toDouble();
    final support3 = math
        .min(supportAt(2, 1.85), support2 - minimumLevelGap)
        .toDouble();

    final resistance = resistanceAt(0, 1.15);
    final resistance2 = math
        .max(resistanceAt(1, 1.50), resistance + minimumLevelGap)
        .toDouble();
    final resistance3 = math
        .max(resistanceAt(2, 1.85), resistance2 + minimumLevelGap)
        .toDouble();

    // ============================================================
    // CROC AI DİNAMİK STOP MOTORU
    // ============================================================
    //
    // Amaç:
    // - Stop, eski ve çok uzaktaki bir desteğe bağlanmamalı.
    // - Hissenin ATR volatilitesi dikkate alınmalı.
    // - Çok dar stop ile gereksiz stop olunmamalı.
    // - %20 - %30 gibi anlamsız stop mesafeleri oluşmamalı.
    //
    // Düşük volatilite  : maksimum yaklaşık %4
    // Orta volatilite   : maksimum yaklaşık %5
    // Yüksek volatilite : maksimum yaklaşık %6,5
    // ============================================================

    final double maxStopPercent;

    if (atrRatio >= 0.045) {
      maxStopPercent = 0.065;
    } else if (atrRatio >= 0.025) {
      maxStopPercent = 0.050;
    } else {
      maxStopPercent = 0.040;
    }

    final double minStopPercent;

    if (atrRatio >= 0.045) {
      minStopPercent = 0.030;
    } else if (atrRatio >= 0.025) {
      minStopPercent = 0.025;
    } else {
      minStopPercent = 0.020;
    }

    // ATR tabanlı doğal stop mesafesi.
    final atrStopDistance = atr * 1.35;

    // Stop mesafesinin alt ve üst sınırı.
    final minimumStopDistance = price * minStopPercent;

    final maximumStopDistance = price * maxStopPercent;

    // ATR stopunu izin verilen risk bandına sıkıştır.
    final controlledStopDistance = math
        .min(
          maximumStopDistance,
          math.max(minimumStopDistance, atrStopDistance),
        )
        .toDouble();

    final volatilityStop = price - controlledStopDistance;

    // 20 günlük destek fiyata gerçekten yakın mı?
    final supportDistancePercent = price <= 0 ? 1.0 : (price - support) / price;

    final supportIsUsable =
        support > 0 &&
        support < price &&
        supportDistancePercent >= 0 &&
        supportDistancePercent <= maxStopPercent;

    // Destek yakınsa biraz altına teknik tampon bırak.
    final technicalSupportStop = support - atr * 0.15;

    double rawStop;

    if (supportIsUsable) {
      // Yakın desteği kullanabiliriz fakat stop,
      // maksimum risk bandının altına kaçamaz.
      rawStop = math.max(technicalSupportStop, volatilityStop).toDouble();
    } else {
      // Destek çok uzaktaysa stop hesabına sokma.
      rawStop = volatilityStop;
    }

    // Stop çok yukarı çıkıp anlamsız derecede darlaşmasın.
    final highestAllowedStop = price * (1 - minStopPercent);

    final stop = math
        .max(0.01, math.min(rawStop, highestAllowedStop))
        .toDouble();

    final stopRiskPercent = price <= 0 ? 0.0 : ((price - stop) / price) * 100;

    final riskPerShare = math.max(price - stop, atr * 0.50).toDouble();

    // ============================================================
    // HEDEF MOTORU
    // ============================================================
    //
    // H1 = yakın teknik hedef
    // H2 = momentum hedefi
    // H3 = agresif hedef
    //
    // Hedeflerin aşırı uzaklaşmasını sınırlandırıyoruz.
    // ============================================================

    final targetCap1 = price * 1.12;
    final targetCap2 = price * 1.20;
    final targetCap3 = price * 1.30;

    final atrTarget1 = price + atr * 1.40;

    final atrTarget2 = price + atr * 2.20;

    final atrTarget3 = price + atr * 3.20;

    final rrTarget1 = price + riskPerShare * 1.20;

    final rrTarget2 = price + riskPerShare * 1.80;

    final rrTarget3 = price + riskPerShare * 2.50;

    final rawTarget1 = math
        .max(atrTarget1, math.min(resistance, rrTarget1))
        .toDouble();

    final rawTarget2 = math
        .max(rawTarget1, math.max(atrTarget2, math.min(resistance2, rrTarget2)))
        .toDouble();

    final rawTarget3 = math
        .max(rawTarget2, math.max(atrTarget3, math.min(resistance3, rrTarget3)))
        .toDouble();

    final target = math.min(rawTarget1, targetCap1).toDouble();

    final target2 = math
        .min(math.max(rawTarget2, target), targetCap2)
        .toDouble();

    final target3 = math
        .min(math.max(rawTarget3, target2), targetCap3)
        .toDouble();

    final riskReward = riskPerShare <= 0
        ? 0.0
        : (target - price) / riskPerShare;

    // ============================================================
    // HACİM
    // ============================================================

    final volumes = lookback20
        .map((e) => e.volume)
        .where((e) => e > 0)
        .toList();

    final averageVolume = volumes.isEmpty
        ? 0.0
        : volumes.reduce((a, b) => a + b) / volumes.length;

    final volumeRatio = averageVolume <= 0 ? 1.0 : last.volume / averageVolume;

    // ============================================================
    // CROC AI SKOR MOTORU
    // ============================================================

    final reasons = <String>[];

    var score = 50.0;

    String trend;

    // Trend
    if (price > ema20 && ema20 > ema50) {
      trend = 'Yükseliş';

      score += 15;

      reasons.add('Fiyat EMA20 üzerinde ve EMA20, EMA50 üzerinde.');
    } else if (price < ema20 && ema20 < ema50) {
      trend = 'Düşüş';

      score -= 15;

      reasons.add('Fiyat EMA20 altında ve kısa vadeli trend zayıf.');
    } else {
      trend = 'Yatay / Kararsız';

      reasons.add('EMA yapısı karışık; trend teyidi henüz güçlü değil.');
    }

    // RSI
    if (rsi >= 50 && rsi <= 68) {
      score += 10;

      reasons.add('RSI pozitif bölgede ve aşırı alım seviyesinde değil.');
    } else if (rsi > 75) {
      score -= 8;

      reasons.add('RSI aşırı alım bölgesinde.');
    } else if (rsi < 35) {
      score -= 6;

      reasons.add('RSI zayıf momentum gösteriyor.');
    }

    // MACD
    if (macdLine > signal && histogram > 0) {
      score += 12;

      reasons.add('MACD pozitif momentum gösteriyor.');
    } else if (macdLine < signal && histogram < 0) {
      score -= 12;

      reasons.add('MACD negatif momentum gösteriyor.');
    }

    // Hacim
    if (volumeRatio >= 1.20) {
      score += 8;

      reasons.add('Hacim son 20 günlük ortalamanın üzerinde.');
    } else if (volumeRatio < 0.70) {
      score -= 4;

      reasons.add('Hacim teyidi zayıf.');
    }

    // Yakın destek bonusu.
    if (price > 0) {
      final supportDistance = ((price - support) / price) * 100;

      if (supportDistance >= 1 && supportDistance <= 8) {
        score += 5;

        reasons.add('Fiyat yakın destek bölgesine kontrollü mesafede.');
      }
    }

    // Teknik merdiven bilgisi.
    reasons.add(
      'Teknik merdiven: S1 ${support.toStringAsFixed(2)} • '
      'S2 ${support2.toStringAsFixed(2)} • '
      'S3 ${support3.toStringAsFixed(2)} / '
      'R1 ${resistance.toStringAsFixed(2)} • '
      'R2 ${resistance2.toStringAsFixed(2)} • '
      'R3 ${resistance3.toStringAsFixed(2)}.',
    );

    // EMA200
    if (ema200 != null) {
      if (price > ema200) {
        score += 5;

        reasons.add('Fiyat EMA200 üzerinde; uzun vadeli yapı olumlu.');
      } else {
        score -= 5;

        reasons.add('Fiyat EMA200 altında; uzun vadeli yapı zayıf.');
      }
    }

    // Risk / Getiri
    if (riskReward >= 1.8) {
      score += 5;

      reasons.add('Risk/getiri oranı güçlü.');
    } else if (riskReward < 1.0) {
      score -= 5;

      reasons.add('Yakın hedefe göre risk/getiri oranı zayıf.');
    }

    // Stop riski
    if (stopRiskPercent <= 3.0) {
      score += 2;

      reasons.add('Stop mesafesi kontrollü risk bölgesinde.');
    } else if (stopRiskPercent > 6.5) {
      score -= 15;

      reasons.add('Stop mesafesi işlem için fazla geniş.');
    }

    final finalScore = score.round().clamp(0, 100).toInt();

    // ============================================================
    // KARAR MOTORU
    // ============================================================

    String decision;

    if (finalScore >= 82) {
      decision = 'GÜÇLÜ AL';
    } else if (finalScore >= 66) {
      decision = 'AL';
    } else if (finalScore >= 45) {
      decision = 'İZLE';
    } else if (finalScore >= 30) {
      decision = 'AZALT';
    } else {
      decision = 'UZAK DUR';
    }

    // Aşırı ısınma ve risk güvenlik katmanı.
    final maximumAllowedRiskPercent = maxStopPercent * 100;
    final strongTrendConfirmation =
        trend == 'Yükseliş' &&
        macdLine > signal &&
        histogram > 0 &&
        volumeRatio >= 1.20;

    if (rsi > 75) {
      if (!strongTrendConfirmation || volumeRatio < 1.50 || riskReward < 1.20) {
        if (decision == 'AL' || decision == 'GÜÇLÜ AL') {
          decision = 'İZLE';
        }
        reasons.add(
          'RSI 75 üzerinde; yeni alım için fiyatın soğuması veya daha güçlü hacim teyidi bekleniyor.',
        );
      } else if (decision == 'GÜÇLÜ AL') {
        decision = 'AL';
        reasons.add(
          'Trend güçlü ancak RSI aşırı alımda; sinyal kontrollü AL seviyesine indirildi.',
        );
      }
    } else if (rsi > 70 && decision == 'GÜÇLÜ AL') {
      decision = 'AL';
      reasons.add(
        'RSI 70 üzerinde; güçlü alış yerine kontrollü alım tercih edildi.',
      );
    }

    if (stopRiskPercent > maximumAllowedRiskPercent + 0.10 &&
        (decision == 'AL' || decision == 'GÜÇLÜ AL')) {
      decision = 'İZLE';
      reasons.add(
        'Teknik görünüm olumlu olsa da stop mesafesi işlem açmak için fazla geniş.',
      );
    }

    if (riskReward < 1.0 && (decision == 'AL' || decision == 'GÜÇLÜ AL')) {
      decision = 'İZLE';
      reasons.add(
        'Yakın hedefe göre risk/getiri oranı yeni işlem için yeterli değil.',
      );
    } else if (riskReward < 1.30 && decision == 'GÜÇLÜ AL') {
      decision = 'AL';
      reasons.add('Risk/getiri olumlu ancak güçlü alış eşiğinin altında.');
    }

    if (atrRatio >= 0.045 && decision == 'GÜÇLÜ AL') {
      decision = 'AL';
      reasons.add(
        'Volatilite yüksek; güçlü alış sinyali kontrollü AL seviyesine indirildi.',
      );
    }

    // ============================================================
    // RİSK SINIFI
    // ============================================================

    final String risk;

    if (atrRatio >= 0.045) {
      risk = 'Yüksek';
    } else if (atrRatio >= 0.025) {
      risk = 'Orta';
    } else {
      risk = 'Düşük';
    }

    return CrocTechnicalAnalysis(
      rsi: rsi,
      macd: macdLine,
      macdSignal: signal,
      macdHistogram: histogram,
      ema20: ema20,
      ema50: ema50,
      ema200: ema200,
      support: support,
      support2: support2,
      support3: support3,
      resistance: resistance,
      resistance2: resistance2,
      resistance3: resistance3,
      stop: stop,
      target: target,
      target2: target2,
      target3: target3,
      atr: atr,
      volumeRatio: volumeRatio,
      riskReward: riskReward,
      score: finalScore,
      decision: decision,
      trend: trend,
      risk: risk,
      reasons: reasons,
    );
  }

  double _ema(List<double> values, int period) {
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

  List<double> _emaSeries(List<double> values, int period) {
    if (values.isEmpty) {
      return const [];
    }

    final result = <double>[];

    var ema = values.first;

    final k = 2.0 / (period + 1);

    for (final value in values) {
      ema = value * k + ema * (1 - k);

      result.add(ema);
    }

    return result;
  }

  List<double> _macdSeries(List<double> closes) {
    final fast = _emaSeries(closes, 12);

    final slow = _emaSeries(closes, 26);

    return List.generate(closes.length, (index) => fast[index] - slow[index]);
  }

  double _rsi(List<double> closes, int period) {
    if (closes.length <= period) {
      return 50;
    }

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

    if (averageLoss == 0) {
      return 100;
    }

    final rs = averageGain / averageLoss;

    return 100 - (100 / (1 + rs));
  }

  double _atr(List<HistoricalCandle> candles, int period) {
    final start = math.max(1, candles.length - period);

    var total = 0.0;
    var count = 0;

    for (var i = start; i < candles.length; i++) {
      final candle = candles[i];

      final previousClose = candles[i - 1].close;

      final trueRange = math.max(
        candle.high - candle.low,
        math.max(
          (candle.high - previousClose).abs(),
          (candle.low - previousClose).abs(),
        ),
      );

      total += trueRange;
      count++;
    }

    return count == 0 ? 0 : total / count;
  }
}
