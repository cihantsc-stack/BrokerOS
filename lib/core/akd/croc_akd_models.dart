enum CrocAkdDataFlag {
  negativeCost,
  zeroBuy,
  zeroSell,
  netMismatch,
  oneSidedFlow,
}

class CrocAkdBrokerRow {
  const CrocAkdBrokerRow({
    required this.institution,
    required this.buyLots,
    required this.buyAverage,
    required this.sellLots,
    required this.sellAverage,
    required this.totalLots,
    required this.sharePercent,
    required this.netLots,
    required this.cost,
  });

  final String institution;
  final double buyLots;
  final double buyAverage;
  final double sellLots;
  final double sellAverage;
  final double totalLots;
  final double sharePercent;
  final double netLots;
  final double cost;

  List<CrocAkdDataFlag> get dataFlags {
    final flags = <CrocAkdDataFlag>[];
    if (cost < 0) flags.add(CrocAkdDataFlag.negativeCost);
    if (buyLots == 0) flags.add(CrocAkdDataFlag.zeroBuy);
    if (sellLots == 0) flags.add(CrocAkdDataFlag.zeroSell);
    if (((buyLots - sellLots) - netLots).abs() > 1.0) {
      flags.add(CrocAkdDataFlag.netMismatch);
    }
    if (totalLots > 0 &&
        (buyLots == 0 || sellLots == 0) &&
        netLots.abs() / totalLots >= 0.95) {
      flags.add(CrocAkdDataFlag.oneSidedFlow);
    }
    return List.unmodifiable(flags);
  }

  bool get isUsable =>
      institution.trim().isNotEmpty &&
      buyLots.isFinite &&
      sellLots.isFinite &&
      totalLots.isFinite &&
      netLots.isFinite &&
      buyLots >= 0 &&
      sellLots >= 0 &&
      totalLots >= 0;
}

enum CrocAkdConcentrationSignal {
  buyerConcentrated,
  sellerConcentrated,
  balanced,
  distorted,
  insufficientData,
}

class CrocAkdResult {
  const CrocAkdResult({
    required this.rows,
    required this.topBuyers,
    required this.topSellers,
    required this.positiveNetLots,
    required this.negativeNetLots,
    required this.buyerConcentrationPercent,
    required this.sellerConcentrationPercent,
    required this.turnoverConcentrationPercent,
    required this.oneSidedTurnoverPercent,
    required this.isFlowDistorted,
    required this.isBalancedNetBook,
    required this.netBookImbalancePercent,
    required this.signal,
  });

  final List<CrocAkdBrokerRow> rows;
  final List<CrocAkdBrokerRow> topBuyers;
  final List<CrocAkdBrokerRow> topSellers;
  final double positiveNetLots;
  final double negativeNetLots;
  final double buyerConcentrationPercent;
  final double sellerConcentrationPercent;
  final double turnoverConcentrationPercent;
  final double oneSidedTurnoverPercent;
  final bool isFlowDistorted;
  final bool isBalancedNetBook;
  final double netBookImbalancePercent;
  final CrocAkdConcentrationSignal signal;
}
