class InstitutionalTrade {
  final DateTime time;
  final double price;
  final double quantity;
  final String? buyer;
  final String? seller;

  const InstitutionalTrade({
    required this.time,
    required this.price,
    required this.quantity,
    this.buyer,
    this.seller,
  });
}

class BrokerFlow {
  final String broker;
  final double buyAmount;
  final double sellAmount;
  final double netAmount;
  final double sharePercent;

  const BrokerFlow({
    required this.broker,
    required this.buyAmount,
    required this.sellAmount,
    required this.netAmount,
    required this.sharePercent,
  });
}

class CustodyPosition {
  final String broker;
  final double currentLots;
  final double previousLots;
  final double changeLots;
  final double sharePercent;

  const CustodyPosition({
    required this.broker,
    required this.currentLots,
    required this.previousLots,
    required this.changeLots,
    required this.sharePercent,
  });
}

class InstitutionalDataBundle {
  final String symbol;
  final String providerName;
  final bool providerConnected;
  final String statusMessage;
  final DateTime? updatedAt;
  final List<InstitutionalTrade> trades;
  final List<BrokerFlow> brokerFlows;
  final List<CustodyPosition> custody;

  const InstitutionalDataBundle({
    required this.symbol,
    required this.providerName,
    required this.providerConnected,
    required this.statusMessage,
    this.updatedAt,
    this.trades = const [],
    this.brokerFlows = const [],
    this.custody = const [],
  });

  bool get hasTrades => trades.isNotEmpty;
  bool get hasBrokerFlows => brokerFlows.isNotEmpty;
  bool get hasCustody => custody.isNotEmpty;
}
