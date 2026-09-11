import 'fund_price_point.dart';

class FundHistoryResult {
  final String fundCode;
  final String? fundName;
  final int periodMonths;
  final List<FundPricePoint> prices;

  final bool available;
  final String provider;
  final String status;
  final DateTime updatedAt;

  const FundHistoryResult({
    required this.fundCode,
    required this.fundName,
    required this.periodMonths,
    required this.prices,
    required this.available,
    required this.provider,
    required this.status,
    required this.updatedAt,
  });

  FundPricePoint? get latest => prices.isEmpty ? null : prices.last;
}
