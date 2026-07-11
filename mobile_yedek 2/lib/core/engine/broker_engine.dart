import '../models/stock_analysis.dart';
import '../scanner/market_scanner.dart';
import '../strategy/strategy_engine.dart';

class BrokerEngine {
  static List<StockAnalysis> run() {
    final candidates = MarketScanner.scan();

    return StrategyEngine.evaluate(candidates);
  }
}