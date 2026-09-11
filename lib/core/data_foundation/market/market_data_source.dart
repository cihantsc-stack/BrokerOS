import 'market_tick.dart';

abstract interface class MarketDataSource {
  String get sourceName;

  Future<MarketTick> fetchQuote(String symbol);

  Stream<MarketTick> watchQuote(String symbol);
}
