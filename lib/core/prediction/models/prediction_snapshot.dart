import '../../models/stock_analysis.dart';

class PredictionSnapshot {
  final String symbol;
  final DateTime createdAt;
  final double referencePrice;
  final int technicalScore;
  final int smartMoneyScore;
  final int institutionalScore;
  final int momentumScore;
  final int newsScore;
  final int riskScore;
  final int activeSignalCount;

  const PredictionSnapshot({
    required this.symbol,
    required this.createdAt,
    required this.referencePrice,
    required this.technicalScore,
    required this.smartMoneyScore,
    required this.institutionalScore,
    required this.momentumScore,
    required this.newsScore,
    required this.riskScore,
    required this.activeSignalCount,
  });

  factory PredictionSnapshot.fromStock(
    StockAnalysis stock, {
    DateTime? createdAt,
  }) {
    final price = (stock.lastPrice ?? stock.entry) > 0
        ? (stock.lastPrice ?? stock.entry)
        : 0.0;
    return PredictionSnapshot(
      symbol: stock.symbol.toUpperCase(),
      createdAt: createdAt ?? DateTime.now(),
      referencePrice: price,
      technicalScore: stock.technicalScore,
      smartMoneyScore: stock.smartMoneyScore,
      institutionalScore: stock.institutionalScore,
      momentumScore: stock.momentumScore,
      newsScore: stock.newsScore,
      riskScore: stock.riskScore,
      activeSignalCount: stock.activeSignalCount,
    );
  }
}
