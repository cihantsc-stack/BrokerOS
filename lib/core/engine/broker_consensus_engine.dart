import '../models/broker_consensus.dart';
import '../models/market_snapshot.dart';

class BrokerConsensusEngine {
  static BrokerConsensus calculate(MarketSnapshot data) {
    int technical = 50;
    int smartMoney = 0;
    int institution = 0;
    int news = 0;
    int momentum = 0;
    int risk = 100;
    int gameTheory = 0;

    final positives = <String>[];
    final negatives = <String>[];

    // ==========================
    // SMART MONEY
    // ==========================

    if (data.smartMoney > 0) {
      smartMoney = 85;
      positives.add('Smart Money');
    } else if (data.smartMoney < 0) {
      smartMoney = 30;
      negatives.add('Smart Money Çıkışı');
    }

    if (data.moneyFlow != 0 || data.foreignRatio > 0) {
      institution = 50;

      if (data.moneyFlow > 0) {
        institution += 20;
        positives.add('Kurumsal Para');
      } else if (data.moneyFlow < 0) {
        institution -= 20;
        negatives.add('Kurumsal Para Çıkışı');
      }

      if (data.foreignRatio > 50) {
        institution += 15;
        positives.add('Yabancı Alımı');
      } else if (data.foreignRatio > 0 && data.foreignRatio < 40) {
        institution -= 10;
        negatives.add('Yabancı Oranı Zayıf');
      }
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

    if (data.newsScore > 0) {
      news = data.newsScore.clamp(0, 100).toInt();

      if (data.newsScore > 75) {
        positives.add('Pozitif Haber');
      } else if (data.newsScore < 40) {
        negatives.add('Haber Etkisi');
      }
    }

    // ==========================
    // MOMENTUM
    // ==========================

    if (data.sentiment != 0) {
      momentum = data.sentiment.clamp(0, 100).toInt();

      if (data.sentiment > 65) {
        positives.add('Momentum');
      } else if (data.sentiment < 40) {
        negatives.add('Momentum Zayıf');
      }
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
    } else if (smartMoney > 0 && institution > 0 && momentum > 0) {
      gameTheory = 65;
    }

    technical = technical.clamp(0, 100).toInt();
    smartMoney = smartMoney.clamp(0, 100).toInt();
    institution = institution.clamp(0, 100).toInt();
    news = news.clamp(0, 100).toInt();
    momentum = momentum.clamp(0, 100).toInt();
    risk = risk.clamp(0, 100).toInt();
    gameTheory = gameTheory.clamp(0, 100).toInt();

    final layers = <(int value, double weight)>[
      (technical, 0.23),
      if (smartMoney > 0) (smartMoney, 0.25),
      if (institution > 0) (institution, 0.18),
      if (news > 0) (news, 0.10),
      if (momentum > 0) (momentum, 0.14),
      (risk, 0.05),
      if (gameTheory > 0) (gameTheory, 0.05),
    ];

    final activeWeight = layers.fold<double>(0, (sum, e) => sum + e.$2);
    final weighted = layers.fold<double>(
      0,
      (sum, e) => sum + (e.$1 * e.$2),
    );
    final score = activeWeight <= 0 ? 0 : (weighted / activeWeight).round();

    final hasDecisionData =
        smartMoney > 0 || institution > 0 || news > 0 || momentum > 0;

    String decision;

    if (!hasDecisionData) {
      decision = 'VERİ BEKLENİYOR';
    } else if (score >= 90) {
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
      confidence: hasDecisionData ? score : 0,
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
