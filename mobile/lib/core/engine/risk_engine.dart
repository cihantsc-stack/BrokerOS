import '../models/market_snapshot.dart';
import '../models/risk_assessment.dart';

class RiskEngine {
  static RiskAssessment evaluate(
    MarketSnapshot data,
  ) {
    int score = 100;
    final reasons = <String>[];

    if (data.volatility >= 80) {
      score -= 35;
      reasons.add('Volatilite çok yüksek.');
    } else if (data.volatility >= 65) {
      score -= 20;
      reasons.add('Volatilite yükseliyor.');
    } else if (data.volatility >= 50) {
      score -= 10;
      reasons.add('Volatilite orta seviyede.');
    }

    if (data.rsi >= 80) {
      score -= 18;
      reasons.add('RSI aşırı alım bölgesinde.');
    } else if (data.rsi >= 70) {
      score -= 10;
      reasons.add('RSI yüksek bölgede.');
    } else if (data.rsi <= 25) {
      score -= 15;
      reasons.add('RSI aşırı satım bölgesinde.');
    } else if (data.rsi <= 35) {
      score -= 8;
      reasons.add('RSI zayıf bölgede.');
    }

    if (data.ema20 < data.ema50) {
      score -= 10;
      reasons.add('Kısa vadeli trend zayıf.');
    }

    if (data.ema50 < data.ema200) {
      score -= 15;
      reasons.add('Ana trend aşağı yönlü.');
    }

    if (data.smartMoney < 0) {
      score -= 18;
      reasons.add('Smart Money çıkışı var.');
    }

    if (data.moneyFlow < 0) {
      score -= 12;
      reasons.add('Kurumsal para akışı negatif.');
    }

    if (data.fundFlow < 0) {
      score -= 8;
      reasons.add('Fon çıkışı görülüyor.');
    }

    if (data.newsScore < 40) {
      score -= 12;
      reasons.add('Haber akışı riskli.');
    } else if (data.newsScore < 60) {
      score -= 6;
      reasons.add('Haber desteği zayıf.');
    }

    if (data.viop < 0) {
      score -= 10;
      reasons.add('VİOP görünümü negatif.');
    }

    score = score.clamp(0, 100).toInt();

    final String level;

    if (score >= 75) {
      level = 'Düşük';
    } else if (score >= 50) {
      level = 'Orta';
    } else {
      level = 'Yüksek';
    }

    if (reasons.isEmpty) {
      reasons.add('Belirgin bir risk sinyali tespit edilmedi.');
    }

    return RiskAssessment(
      score: score,
      level: level,
      reasons: List.unmodifiable(reasons),
    );
  }
}