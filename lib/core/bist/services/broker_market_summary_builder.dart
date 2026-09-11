import 'bist100_live_intelligence_service.dart';

class BrokerMarketSummary {
  final String decision;
  final int score;
  final int confidence;
  final String headline;
  final String explanation;

  const BrokerMarketSummary({
    required this.decision,
    required this.score,
    required this.confidence,
    required this.headline,
    required this.explanation,
  });
}

class BrokerMarketSummaryBuilder {
  const BrokerMarketSummaryBuilder();

  BrokerMarketSummary build(Bist100LiveIntelligenceResult result) {
    final breadth = result.intelligence.breadth;
    final sectors = result.intelligence.sectors;
    final strongest = result.intelligence.strongestStocks;

    final String leadingSector = sectors.isEmpty
        ? 'Veri yok'
        : sectors.first.sector;
    final String strongestStock = strongest.isEmpty
        ? 'Veri yok'
        : strongest.first.stock.code;

    final int score = breadth.score;
    final int confidence = result.marketData.isFallback ? 58 : 88;

    String decision;
    if (score >= 75) {
      decision = 'GÜÇLÜ POZİTİF';
    } else if (score >= 60) {
      decision = 'SEÇİCİ ALIM';
    } else if (score >= 42) {
      decision = 'TEMKİNLİ BEKLE';
    } else if (score >= 25) {
      decision = 'RİSK AZALT';
    } else {
      decision = 'SAVUNMA MODU';
    }

    final String headline =
        '$leadingSector lider, en güçlü hisse $strongestStock';

    final String explanation =
        'BIST 100 içinde ${breadth.rising} hisse yükseliyor, '
        '${breadth.falling} hisse düşüyor ve ${breadth.flat} hisse yatay. '
        'Ortalama değişim %${breadth.averageChange.toStringAsFixed(2)}. '
        'Piyasa genişliği skoru $score/100.';

    return BrokerMarketSummary(
      decision: decision,
      score: score,
      confidence: confidence,
      headline: headline,
      explanation: explanation,
    );
  }
}
