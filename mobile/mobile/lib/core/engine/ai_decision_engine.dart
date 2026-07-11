import '../models/ai_decision.dart';
import '../models/stock_analysis.dart';

class AiDecisionEngine {
  const AiDecisionEngine._();

  static AiDecision build(StockAnalysis stock) {
    final scores = <String, int>{
      'Teknik görünüm': stock.technicalScore,
      'Smart Money': stock.smartMoneyScore,
      'Kurumsal hareket': stock.institutionalScore,
      'Haber etkisi': stock.newsScore,
      'Risk kalitesi': stock.riskScore,
      'Momentum': stock.momentumScore,
    };

    final strongest = scores.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    final weakest = scores.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    );

    final score = stock.brokerConsensus;
    final confidence = stock.confidence.clamp(0, 100);

    return AiDecision(
      symbol: stock.symbol,
      decision: stock.decision,
      score: score,
      confidence: confidence,
      risk: stock.risk,
      summary: _summary(stock, strongest.key),
      strongestReason: strongest.key,
      biggestRisk: _biggestRisk(stock, weakest.key),
      todayMission: [
        'Açılışın ilk 15 dakikasında hacim teyidi bekle.',
        'Kademeli işlem yap ve stop seviyesine sadık kal.',
        'Smart Money yön değiştirirse pozisyonu yeniden değerlendir.',
      ],
      watchList: [
        'Stop: ${stock.stop.toStringAsFixed(2)}',
        'Hedef 1: ${stock.target1.toStringAsFixed(2)}',
        'Hedef 2: ${stock.target2.toStringAsFixed(2)}',
      ],
      nextTrigger:
          '${stock.stop.toStringAsFixed(2)} altında günlük kapanışta karar yeniden hesaplanır.',
    );
  }

  static String _summary(StockAnalysis stock, String strongestReason) {
    final direction = stock.decision.contains('AL')
        ? 'pozitif'
        : stock.decision.contains('SAT')
            ? 'negatif'
            : 'temkinli';

    return '${stock.symbol} için birleşik görünüm $direction. '
        'En güçlü katkı $strongestReason tarafından geliyor. '
        'Broker Consensus ${stock.brokerConsensus}/100 seviyesinde. '
        'Risk ${stock.risk.toLowerCase()} olduğu için işlem planı stop disipliniyle uygulanmalı.';
  }

  static String _biggestRisk(StockAnalysis stock, String weakestFactor) {
    if (stock.risk.toLowerCase().contains('yüksek')) {
      return 'Yüksek volatilite ve hızlı yön değişimi riski.';
    }

    if (stock.riskScore < 70) {
      return 'Risk kalitesi zayıf; stop seviyesine yaklaşım dikkatle izlenmeli.';
    }

    return '$weakestFactor kararın en zayıf bileşeni.';
  }
}
