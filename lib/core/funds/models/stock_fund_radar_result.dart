class StockFundPosition {
  final String fundCode;
  final String period;
  final String? publishDate;
  final String symbol;
  final String? name;
  final double weight;
  final double fpdWeight;
  final double value;
  final double nominal;

  const StockFundPosition({
    required this.fundCode,
    required this.period,
    required this.publishDate,
    required this.symbol,
    required this.name,
    required this.weight,
    required this.fpdWeight,
    required this.value,
    required this.nominal,
  });

  factory StockFundPosition.fromJson(Map<String, dynamic> json) {
    return StockFundPosition(
      fundCode: json['fundCode']?.toString().trim().toUpperCase() ?? '',
      period: json['period']?.toString() ?? '',
      publishDate: json['publishDate']?.toString(),
      symbol: json['symbol']?.toString().trim().toUpperCase() ?? '',
      name: json['name']?.toString(),
      weight: _toDouble(json['weight']),
      fpdWeight: _toDouble(json['fpdWeight']),
      value: _toDouble(json['value']),
      nominal: _toDouble(json['nominal']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class StockFundRadarResult {
  final bool available;
  final String symbol;
  final String? activePeriod;
  final int holderFundCount;
  final double totalValue;
  final double totalNominal;
  final double averageWeight;
  final List<StockFundPosition> funds;
  final String? status;

  const StockFundRadarResult({
    required this.available,
    required this.symbol,
    required this.activePeriod,
    required this.holderFundCount,
    required this.totalValue,
    required this.totalNominal,
    required this.averageWeight,
    required this.funds,
    required this.status,
  });

  factory StockFundRadarResult.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : <String, dynamic>{};

    final rawFunds = json['funds'];

    final funds = <StockFundPosition>[];

    if (rawFunds is List) {
      for (final item in rawFunds) {
        if (item is Map) {
          funds.add(
            StockFundPosition.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    funds.sort((a, b) => b.value.compareTo(a.value));

    return StockFundRadarResult(
      available: json['available'] == true,
      symbol: json['symbol']?.toString().trim().toUpperCase() ?? '',
      activePeriod: json['activePeriod']?.toString(),
      holderFundCount: _toInt(json['holderFundCount']),
      totalValue: _toDouble(summary['totalValue']),
      totalNominal: _toDouble(summary['totalNominal']),
      averageWeight: _toDouble(summary['averageWeight']),
      funds: List<StockFundPosition>.unmodifiable(funds),
      status: json['status']?.toString(),
    );
  }

  factory StockFundRadarResult.unavailable({
    required String symbol,
    String? status,
  }) {
    return StockFundRadarResult(
      available: false,
      symbol: symbol,
      activePeriod: null,
      holderFundCount: 0,
      totalValue: 0,
      totalNominal: 0,
      averageWeight: 0,
      funds: const [],
      status: status,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
