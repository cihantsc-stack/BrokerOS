enum CrocAkdBalance { buyerConcentrated, balanced, sellerConcentrated }

class CrocAkdBrokerRow {
  const CrocAkdBrokerRow({
    required this.institution,
    required this.buyLots,
    required this.sellLots,
    required this.totalLots,
    required this.netLots,
    this.cost,
  });

  final String institution;
  final double buyLots;
  final double sellLots;
  final double totalLots;
  final double netLots;
  final double? cost;

  bool get isValid =>
      institution.trim().isNotEmpty &&
      buyLots.isFinite &&
      sellLots.isFinite &&
      totalLots.isFinite &&
      netLots.isFinite &&
      buyLots >= 0 &&
      sellLots >= 0 &&
      totalLots >= 0 &&
      (cost == null || (cost!.isFinite && cost! >= 0));
}

class CrocAkdResult {
  const CrocAkdResult({
    required this.buyers,
    required this.sellers,
    required this.positiveNetLots,
    required this.negativeNetLots,
    required this.topBuyerConcentration,
    required this.topSellerConcentration,
    required this.balance,
  });

  final List<CrocAkdBrokerRow> buyers;
  final List<CrocAkdBrokerRow> sellers;
  final double positiveNetLots;
  final double negativeNetLots;
  final double topBuyerConcentration;
  final double topSellerConcentration;
  final CrocAkdBalance balance;
}

class CrocAkdEngine {
  const CrocAkdEngine({this.topCount = 5, this.balanceBand = 0.05});

  final int topCount;
  final double balanceBand;

  CrocAkdResult evaluate(Iterable<CrocAkdBrokerRow> rows) {
    if (topCount < 1) throw ArgumentError.value(topCount, 'topCount');
    final valid = rows.where((row) => row.isValid).toList();
    final buyers = valid.where((row) => row.netLots > 0).toList()
      ..sort((a, b) => b.netLots.compareTo(a.netLots));
    final sellers = valid.where((row) => row.netLots < 0).toList()
      ..sort((a, b) => a.netLots.compareTo(b.netLots));

    final positive = buyers.fold<double>(0, (sum, row) => sum + row.netLots);
    final negative =
        sellers.fold<double>(0, (sum, row) => sum + row.netLots.abs());
    final topBuy = buyers
        .take(topCount)
        .fold<double>(0, (sum, row) => sum + row.netLots);
    final topSell = sellers
        .take(topCount)
        .fold<double>(0, (sum, row) => sum + row.netLots.abs());
    final buyConcentration = positive == 0 ? 0.0 : topBuy / positive;
    final sellConcentration = negative == 0 ? 0.0 : topSell / negative;
    final delta = buyConcentration - sellConcentration;

    return CrocAkdResult(
      buyers: List.unmodifiable(buyers.take(topCount)),
      sellers: List.unmodifiable(sellers.take(topCount)),
      positiveNetLots: positive,
      negativeNetLots: negative,
      topBuyerConcentration: buyConcentration,
      topSellerConcentration: sellConcentration,
      balance: delta.abs() <= balanceBand
          ? CrocAkdBalance.balanced
          : delta > 0
              ? CrocAkdBalance.buyerConcentrated
              : CrocAkdBalance.sellerConcentrated,
    );
  }
}
