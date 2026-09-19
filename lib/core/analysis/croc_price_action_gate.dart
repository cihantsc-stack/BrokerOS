import 'croc_technical_analysis.dart';

class CrocPriceActionGateResult {
  final bool allowBuy;
  final int score;
  final String state;
  final List<String> reasons;

  const CrocPriceActionGateResult({
    required this.allowBuy,
    required this.score,
    required this.state,
    required this.reasons,
  });
}

class CrocPriceActionGate {
  const CrocPriceActionGate();

  CrocPriceActionGateResult evaluate({
    required CrocTechnicalAnalysis analysis,
    required double livePrice,
    required double changePercent,
  }) {
    if (livePrice <= 0) {
      return const CrocPriceActionGateResult(
        allowBuy: false,
        score: 0,
        state: 'VERI YOK',
        reasons: ['Geçerli fiyat yok'],
      );
    }

    var score = 50.0;
    final reasons = <String>[];

    // ----------------------------------------------------------
    // 1. TREND YAPISI
    // ----------------------------------------------------------

    if (livePrice > analysis.ema20 && analysis.ema20 > analysis.ema50) {
      score += 18;
      reasons.add('Fiyat EMA20 üstü, EMA20 > EMA50');
    } else if (livePrice >= analysis.ema20) {
      score += 6;
      reasons.add('Fiyat EMA20 üstünde');
    } else {
      score -= 18;
      reasons.add('Fiyat EMA20 altında');
    }

    if (analysis.ema200 != null) {
      if (livePrice >= analysis.ema200!) {
        score += 5;
      } else {
        score -= 7;
        reasons.add('Fiyat EMA200 altında');
      }
    }

    // ----------------------------------------------------------
    // 2. MOMENTUM
    // ----------------------------------------------------------

    if (analysis.macd > analysis.macdSignal && analysis.macdHistogram > 0) {
      score += 10;
      reasons.add('MACD pozitif');
    } else if (analysis.macd < analysis.macdSignal &&
        analysis.macdHistogram < 0) {
      score -= 10;
      reasons.add('MACD negatif');
    }

    if (analysis.rsi >= 50 && analysis.rsi <= 68) {
      score += 8;
      reasons.add('RSI sağlıklı bölgede');
    } else if (analysis.rsi > 78) {
      score -= 20;
      reasons.add('RSI aşırı ısınmış');
    } else if (analysis.rsi > 70) {
      score -= 8;
      reasons.add('RSI yüksek');
    } else if (analysis.rsi < 40) {
      score -= 6;
      reasons.add('Momentum zayıf');
    }

    // ----------------------------------------------------------
    // 3. FİYATIN DESTEĞE / EMA20'YE KONUMU
    // ----------------------------------------------------------

    final supportDistance = ((livePrice - analysis.support) / livePrice) * 100;

    final ema20Distance = ((livePrice - analysis.ema20) / livePrice) * 100;

    if (supportDistance >= 0 && supportDistance <= 3.5) {
      score += 10;
      reasons.add('Yakın destek bölgesi');
    } else if (supportDistance > 7) {
      score -= 5;
      reasons.add('Destekten uzak');
    }

    if (ema20Distance >= 0 && ema20Distance <= 2.5) {
      score += 8;
      reasons.add('EMA20 yakınında');
    } else if (ema20Distance > 6) {
      score -= 8;
      reasons.add('EMA20 üzerinden fazla uzaklaşmış');
    }

    // ----------------------------------------------------------
    // 4. HACİM
    // ----------------------------------------------------------

    if (analysis.volumeRatio >= 1.5) {
      score += 8;
      reasons.add('Hacim güçlü');
    } else if (analysis.volumeRatio >= 1.15) {
      score += 4;
    } else if (analysis.volumeRatio < 0.70) {
      score -= 7;
      reasons.add('Hacim zayıf');
    }

    // ----------------------------------------------------------
    // 5. RİSK / GETİRİ
    // ----------------------------------------------------------

    final risk = livePrice - analysis.stop;
    final reward = analysis.target - livePrice;

    final currentRiskReward = risk > 0 && reward > 0 ? reward / risk : 0.0;

    if (currentRiskReward >= 2.0) {
      score += 10;
      reasons.add('R/G güçlü');
    } else if (currentRiskReward >= 1.4) {
      score += 5;
    } else if (currentRiskReward < 1.20) {
      score -= 15;
      reasons.add('R/G yetersiz');
    }

    // ----------------------------------------------------------
    // 6. HAREKETİ KOVALAMA FRENİ
    // ----------------------------------------------------------

    if (changePercent >= 8.0) {
      score -= 25;
      reasons.add('Günlük hareket fazla koşmuş');
    } else if (changePercent >= 6.0) {
      score -= 12;
      reasons.add('Günlük yükseliş yüksek');
    } else if (changePercent >= 4.0) {
      score -= 5;
    }

    final finalScore = score.round().clamp(0, 100);

    // ----------------------------------------------------------
    // HARD BLOCK
    // ----------------------------------------------------------

    final hardBlock =
        livePrice < analysis.ema20 ||
        analysis.rsi >= 80 ||
        currentRiskReward < 1.0 ||
        analysis.stop <= 0 ||
        analysis.stop >= livePrice ||
        analysis.target <= livePrice ||
        changePercent >= 9.5;

    if (hardBlock) {
      return CrocPriceActionGateResult(
        allowBuy: false,
        score: finalScore,
        state: 'GIRIS YOK',
        reasons: reasons,
      );
    }

    if (finalScore >= 78) {
      return CrocPriceActionGateResult(
        allowBuy: true,
        score: finalScore,
        state: 'SIMDI GIRILEBILIR',
        reasons: reasons,
      );
    }

    if (finalScore >= 65) {
      return CrocPriceActionGateResult(
        allowBuy: false,
        score: finalScore,
        state: 'GIRIS BEKLE',
        reasons: reasons,
      );
    }

    return CrocPriceActionGateResult(
      allowBuy: false,
      score: finalScore,
      state: 'UYGUN DEGIL',
      reasons: reasons,
    );
  }
}
