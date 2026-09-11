import '../../models/stock_analysis.dart';
import '../data/bist_symbol_catalog.dart';
import '../models/radar_opportunity.dart';

class AiRadarEngine {
  const AiRadarEngine();

  RadarOpportunity analyze(StockAnalysis stock) {
    final int combinedScore = _combinedScore(stock);
    final String decision = _decisionFor(combinedScore);
    final String tradeWindow = _tradeWindowFor(combinedScore, stock.risk);

    final double entry = stock.entry > 0 ? stock.entry : (stock.lastPrice ?? 0);

    final double target = stock.target1 > entry ? stock.target1 : 0;

    final double stop = stock.stop > 0 && stock.stop < entry ? stock.stop : 0;

    return RadarOpportunity(
      symbol: stock.symbol,
      company: stock.company,
      score: combinedScore,
      confidence: stock.confidence.clamp(0, 100),
      decision: decision,
      risk: stock.risk,
      tradeWindow: tradeWindow,
      entry: entry,
      target: target,
      stop: stop,
      reasons: _reasons(stock, combinedScore),
    );
  }

  StockAnalysis buildSyntheticAnalysis(String rawSymbol) {
    final String symbol = rawSymbol.trim().toUpperCase();

    return StockAnalysis(
      symbol: symbol,
      company: BistSymbolCatalog.companyOf(symbol),
      aiScore: 0,
      decision: 'VERİ BEKLENİYOR',
      entry: 0,
      target1: 0,
      target2: 0,
      stop: 0,
      confidence: 0,
      risk: 'VERİ BEKLENİYOR',
      reasons: const <String>['Canlı analiz verisi henüz yüklenmedi.'],
      technicalScore: 0,
      smartMoneyScore: 0,
      institutionalScore: 0,
      newsScore: 0,
      riskScore: 0,
      momentumScore: 0,
    );
  }

  int _combinedScore(StockAnalysis stock) {
    return stock.brokerConsensus.clamp(0, 100);
  }

  String _decisionFor(int score) {
    if (score <= 0) return 'VERİ BEKLENİYOR';
    if (score >= 84) return 'GÜÇLÜ AL';
    if (score >= 72) return 'SEÇİCİ AL';
    if (score >= 58) return 'İZLE';
    if (score >= 44) return 'TEYİT BEKLE';
    return 'UZAK DUR';
  }

  String _tradeWindowFor(int score, String risk) {
    if (score <= 0) return 'Veri bekleniyor';

    if (score >= 84 && !risk.toUpperCase().contains('YÜKSEK')) {
      return '1-3 Gün';
    }

    if (score >= 70) {
      return '3-7 Gün';
    }

    return 'İzleme';
  }

  List<String> _reasons(StockAnalysis stock, int score) {
    final List<String> reasons = <String>[];

    if (stock.technicalScore > 0) {
      reasons.add('Teknik veri aktif');
    }

    if (stock.momentumScore > 0) {
      reasons.add('Momentum verisi aktif');
    }

    if (stock.riskScore > 0) {
      reasons.add('Risk motoru aktif');
    }

    if (stock.smartMoneyScore <= 0) {
      reasons.add('Smart Money verisi bekleniyor');
    }

    if (stock.institutionalScore <= 0) {
      reasons.add('Kurumsal veri bekleniyor');
    }

    if (stock.newsScore <= 0) {
      reasons.add('Haber verisi bekleniyor');
    }

    return reasons.take(4).toList();
  }
}
