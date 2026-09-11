import '../models/stock_analysis.dart';

class StrategyEngine {
  static List<StockAnalysis> evaluate(List<StockAnalysis> stocks) {
    final result = stocks.map(_calculateBrokerConsensus).toList();

    result.sort((a, b) => b.brokerConsensus.compareTo(a.brokerConsensus));

    return result;
  }

  static StockAnalysis _calculateBrokerConsensus(StockAnalysis stock) {
    final score = stock.brokerConsensus;

    if (score <= 0) {
      return stock;
    }

    final String decision;

    if (score >= 84) {
      decision = 'GÜÇLÜ AL';
    } else if (score >= 72) {
      decision = 'SEÇİCİ AL';
    } else if (score >= 58) {
      decision = 'İZLE';
    } else if (score >= 44) {
      decision = 'TEYİT BEKLE';
    } else {
      decision = 'UZAK DUR';
    }

    return StockAnalysis(
      symbol: stock.symbol,
      company: stock.company,
      aiScore: score,
      decision: decision,
      entry: stock.entry,
      target1: stock.target1,
      target2: stock.target2,
      stop: stock.stop,
      confidence: score,
      risk: stock.risk,
      reasons: stock.reasons,
      lastPrice: stock.lastPrice,
      dailyChange: stock.dailyChange,
      volume: stock.volume,
      firstInstitution: stock.firstInstitution,
      secondInstitution: stock.secondInstitution,
      thirdInstitution: stock.thirdInstitution,
      smartMoneyFlow: stock.smartMoneyFlow,
      technicalScore: stock.technicalScore,
      smartMoneyScore: stock.smartMoneyScore,
      institutionalScore: stock.institutionalScore,
      newsScore: stock.newsScore,
      riskScore: stock.riskScore,
      momentumScore: stock.momentumScore,
    );
  }
}
