import '../models/broker_consensus.dart';
import '../models/market_snapshot.dart';

class BrokerConsensusEngine {
  static BrokerConsensus calculate(MarketSnapshot data) {
    int technical = 50;
    int smartMoney = 50;
    int institution = 50;
    int news = 50;
    int momentum = 50;
    int risk = 100;
    int gameTheory = 50;

    final positives = <String>[];
    final negatives = <String>[];

    // ==========================
    // SMART MONEY
    // ==========================

    if (data.smartMoney > 0) {
      smartMoney += 35;
      positives.add('Smart Money');
    } else {
      smartMoney -= 20;
      negatives.add('Smart Money Çıkışı');
    }

    if (data.moneyFlow > 0) {
      institution += 20;
      positives.add('Kurumsal Para');
    }

    if (data.foreignRatio > 50) {
      institution += 15;
      positives.add('Yabancı Alımı');
    }

    // ==========================
    // TEKNİK
    // ==========================

    if (data.rsi > 50 && data.rsi < 70) {
      technical += 15;
      positives.add('RSI');
    }

    if (data.macd > 0) {
      technical += 15;
      positives.add('MACD');
    }

    if (data.ema20 > data.ema50) {
      technical += 10;
      positives.add('EMA20');
    }

    if (data.ema50 > data.ema200) {
      technical += 10;
      positives.add('EMA50');
    }

    // ==========================
    // HABER
    // ==========================

    news += (data.newsScore / 4).round();

    if (data.newsScore > 75) {
      positives.add('Pozitif Haber');
    } else {
      negatives.add('Haber Etkisi');
    }

    // ==========================
    // MOMENTUM
    // ==========================

    momentum += (data.sentiment / 4).round();

    if (data.sentiment > 65) {
      positives.add('Momentum');
    }

    // ==========================
    // RİSK
    // ==========================

    if (data.volatility > 70) {
      risk -= 35;
      negatives.add('Yüksek Volatilite');
    } else {
      positives.add('Volatilite Kontrolü');
    }

    // ==========================
    // GAME THEORY
    // ==========================

    if (smartMoney > 80 && institution > 80 && momentum > 70) {
      gameTheory = 92;
      positives.add('Game Theory');
    } else {
      gameTheory = 70;
    }

    technical = technical.clamp(0, 100).toInt();
    smartMoney = smartMoney.clamp(0, 100).toInt();
    institution = institution.clamp(0, 100).toInt();
    news = news.clamp(0, 100).toInt();
    momentum = momentum.clamp(0, 100).toInt();
    risk = risk.clamp(0, 100).toInt();
    gameTheory = gameTheory.clamp(0, 100).toInt();

    final score =
        (technical * 0.23 +
                smartMoney * 0.25 +
                institution * 0.18 +
                news * 0.10 +
                momentum * 0.14 +
                risk * 0.05 +
                gameTheory * 0.05)
            .round();

    String decision;

    if (score >= 90) {
      decision = 'GÜÇLÜ AL';
    } else if (score >= 80) {
      decision = 'AL';
    } else if (score >= 65) {
      decision = 'İZLE';
    } else if (score >= 50) {
      decision = 'BEKLE';
    } else {
      decision = 'SAT';
    }

    return BrokerConsensus(
      score: score,
      decision: decision,
      technicalScore: technical,
      smartMoneyScore: smartMoney,
      institutionScore: institution,
      newsScore: news,
      momentumScore: momentum,
      riskScore: risk,
      gameTheoryScore: gameTheory,
      confidence: score,
      buySignals: positives.length,
      holdSignals: 3,
      sellSignals: negatives.length,
      buyProbability: score / 100,
      sellProbability: (100 - score) / 100,
      explanation:
          'Broker Consensus; teknik analiz, Smart Money, kurumsal hareketler, haber akışı, momentum ve risk motorlarının birleşik değerlendirmesiyle oluşturuldu.',
      positives: positives,
      negatives: negatives,
    );
  }
}
