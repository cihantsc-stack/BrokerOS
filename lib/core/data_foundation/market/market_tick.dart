class MarketTick {
  final String symbol;
  final double price;
  final double changePercent;
  final double volume;
  final DateTime timestamp;
  final String source;

  const MarketTick({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.volume,
    required this.timestamp,
    required this.source,
  });

  bool get isPositive => changePercent >= 0.0;

  MarketTick copyWith({
    double? price,
    double? changePercent,
    double? volume,
    DateTime? timestamp,
    String? source,
  }) {
    return MarketTick(
      symbol: symbol,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }
}
