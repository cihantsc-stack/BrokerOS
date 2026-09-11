class FundFlowData {
  final String symbol;
  final double weeklyFlow;
  final double monthlyFlow;
  final int score;
  final DateTime updatedAt;
  final bool available;
  final String status;

  const FundFlowData({
    required this.symbol,
    required this.weeklyFlow,
    required this.monthlyFlow,
    required this.score,
    required this.updatedAt,
    this.available = false,
    this.status = 'Fon veri kaynagi bekleniyor',
  });
}

abstract interface class FundProvider {
  Future<FundFlowData> fetch(String symbol);
}

class UnavailableFundProvider implements FundProvider {
  const UnavailableFundProvider();

  @override
  Future<FundFlowData> fetch(String symbol) async {
    return FundFlowData(
      symbol: symbol.trim().toUpperCase().replaceAll('.IS', ''),
      weeklyFlow: 0,
      monthlyFlow: 0,
      score: 0,
      updatedAt: DateTime.now(),
      available: false,
      status: 'GERCEK FON AKIS VERISI BEKLENIYOR',
    );
  }
}
