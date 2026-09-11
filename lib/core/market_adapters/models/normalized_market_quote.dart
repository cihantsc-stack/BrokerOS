import 'market_asset_type.dart';

class NormalizedMarketQuote {
  final String symbol;
  final String displayName;
  final MarketAssetType assetType;
  final double price;
  final double changePercent;
  final double volume;
  final String currency;
  final String source;
  final DateTime timestamp;
  final bool delayed;

  const NormalizedMarketQuote({
    required this.symbol,
    required this.displayName,
    required this.assetType,
    required this.price,
    required this.changePercent,
    required this.volume,
    required this.currency,
    required this.source,
    required this.timestamp,
    this.delayed = false,
  });

  bool get isPositive => changePercent >= 0;

  NormalizedMarketQuote copyWith({
    String? displayName,
    double? price,
    double? changePercent,
    double? volume,
    String? currency,
    String? source,
    DateTime? timestamp,
    bool? delayed,
  }) {
    return NormalizedMarketQuote(
      symbol: symbol,
      displayName: displayName ?? this.displayName,
      assetType: assetType,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      delayed: delayed ?? this.delayed,
    );
  }
}
