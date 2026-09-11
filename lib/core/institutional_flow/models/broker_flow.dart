class BrokerFlow {
  final String brokerName;
  final double netLot;
  final double netValue;
  final double averagePrice;
  final double marketShare;
  final bool buyer;

  const BrokerFlow({
    required this.brokerName,
    required this.netLot,
    required this.netValue,
    required this.averagePrice,
    required this.marketShare,
    required this.buyer,
  });
}
