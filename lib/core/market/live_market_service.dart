import 'dart:async';

class MarketSnapshot {
  final String symbol;
  final double lastPrice;
  final double change;
  final double changePercent;
  final double volume;
  final double dayHigh;
  final double dayLow;
  final double open;
  final DateTime updateTime;

  const MarketSnapshot({
    required this.symbol,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.dayHigh,
    required this.dayLow,
    required this.open,
    required this.updateTime,
  });
}

abstract class LiveMarketProvider {
  Future<MarketSnapshot> getSnapshot(String symbol);

  Stream<MarketSnapshot> watch(String symbol);
}

class MockLiveMarketService implements LiveMarketProvider {
  const MockLiveMarketService();

  @override
  Future<MarketSnapshot> getSnapshot(String symbol) async {
    return MarketSnapshot(
      symbol: symbol,
      lastPrice: 156.72,
      change: 4.18,
      changePercent: 2.74,
      volume: 1842000000,
      dayHigh: 157.84,
      dayLow: 152.40,
      open: 153.10,
      updateTime: DateTime.now(),
    );
  }

  @override
  Stream<MarketSnapshot> watch(String symbol) async* {
    while (true) {
      yield await getSnapshot(symbol);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
