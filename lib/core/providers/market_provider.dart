import '../data_foundation/market/yahoo_bist_market_data_source.dart';

class MarketSnapshotData {
  final String symbol;
  final double price;
  final double changePercent;
  final double volume;
  final DateTime updatedAt;
  final bool available;
  final String source;

  const MarketSnapshotData({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.volume,
    required this.updatedAt,
    this.available = true,
    this.source = 'CROC Data Gateway',
  });
}

abstract interface class MarketProvider {
  Future<MarketSnapshotData> fetch(String symbol);
}

class CrocLiveMarketProvider implements MarketProvider {
  final YahooBistMarketDataSource source;

  CrocLiveMarketProvider({YahooBistMarketDataSource? source})
    : source = source ?? YahooBistMarketDataSource();

  @override
  Future<MarketSnapshotData> fetch(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase().replaceAll('.IS', '');

    final snapshot = await source.fetch(
      cleanSymbol,
      range: '1y',
      interval: '1d',
    );

    return MarketSnapshotData(
      symbol: cleanSymbol,
      price: snapshot.tick.price,
      changePercent: snapshot.tick.changePercent,
      volume: snapshot.tick.volume,
      updatedAt: snapshot.tick.timestamp,
      available: true,
      source: snapshot.tick.source,
    );
  }
}
