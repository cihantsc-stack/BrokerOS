import 'dart:async';

import 'market_data_source.dart';
import 'market_tick.dart';

class MockMarketDataSource implements MarketDataSource {
  @override
  String get sourceName => 'BROKER MOCK FEED';

  @override
  Future<MarketTick> fetchQuote(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));

    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    final double price = 80.0 + (seed % 275);
    final double change = ((seed % 48) - 18) / 10.0;
    final double volume = 250000000 + (seed * 1450000);

    return MarketTick(
      symbol: symbol,
      price: price,
      changePercent: change,
      volume: volume,
      timestamp: DateTime.now(),
      source: sourceName,
    );
  }

  @override
  Stream<MarketTick> watchQuote(String symbol) async* {
    while (true) {
      yield await fetchQuote(symbol);
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }
}
