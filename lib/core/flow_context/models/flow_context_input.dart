class FlowBrokerPosition {
  final String institution;
  final double netLot;
  final double? averagePrice;
  final double? marketShare;

  const FlowBrokerPosition({
    required this.institution,
    required this.netLot,
    this.averagePrice,
    this.marketShare,
  });

  bool get isBuyer => netLot > 0;
  bool get isSeller => netLot < 0;
}

class FlowFundPositionChange {
  final String fundCode;
  final double? previousLot;
  final double? currentLot;
  final double? portfolioWeightPercent;

  const FlowFundPositionChange({
    required this.fundCode,
    this.previousLot,
    this.currentLot,
    this.portfolioWeightPercent,
  });

  double? get lotChange {
    if (previousLot == null || currentLot == null) {
      return null;
    }
    return currentLot! - previousLot!;
  }
}

class FlowContextInput {
  final String symbol;
  final double? priceChangePercent;
  final double? volumeRatio;

  final List<FlowBrokerPosition> brokers;
  final List<FlowFundPositionChange> fundChanges;

  final bool institutionalDataAvailable;
  final bool fundDataAvailable;
  final bool crossAssetDataAvailable;

  final DateTime observedAt;

  const FlowContextInput({
    required this.symbol,
    this.priceChangePercent,
    this.volumeRatio,
    this.brokers = const <FlowBrokerPosition>[],
    this.fundChanges = const <FlowFundPositionChange>[],
    this.institutionalDataAvailable = false,
    this.fundDataAvailable = false,
    this.crossAssetDataAvailable = false,
    required this.observedAt,
  });

  bool get hasPriceContext => priceChangePercent != null;
  bool get hasVolumeContext => volumeRatio != null;
}
