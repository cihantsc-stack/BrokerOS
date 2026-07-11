import '../models/ai_decision.dart';
import '../models/market_snapshot.dart';

class BrokerAiEngine {
  static AiDecision analyze(
    MarketSnapshot data,
  ) {
    int score = 50;

    if (data.moneyFlow > 0) score += 10;

    if (data.smartMoney > 0) score += 10;

    if (data.foreignRatio > 50) score += 8;

    if (data.fundFlow > 0) score += 8;

    if (data.rsi > 50 && data.rsi < 70) score += 8;

    if (data.macd > 0) score += 8;

    if (data.newsScore > 70) score += 6;

    if (data.sentiment > 60) score += 5;

    if (data.volatility > 70) score -= 10;

    if (score > 100) score = 100;

    String decision;

    if (score >= 85) {
      decision = "GÜÇLÜ AL";
    } else if (score >= 70) {
      decision = "AL";
    } else if (score >= 55) {
      decision = "İZLE";
    } else {
      decision = "BEKLE";
    }

    return AiDecision(
      pusuScore: score,
      decision: decision,
      explanation:
          "Karar Smart Money, RSI, MACD, EMA, Haber Skoru ve Para Akışı analiz edilerek üretildi.",
      confidence: score,
      risk: score > 80 ? "Düşük" : "Orta",
    );
  }
}