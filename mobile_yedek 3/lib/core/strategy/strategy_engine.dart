import '../models/stock_analysis.dart';

class StrategyEngine {
  static List<StockAnalysis> evaluate(
    List<StockAnalysis> stocks,
  ) {
    final result = [...stocks];

    result.sort(
      (a, b) => b.aiScore.compareTo(a.aiScore),
    );

    return result;
  }
}