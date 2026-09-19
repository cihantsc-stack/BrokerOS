class FundFlowPoint {
  final DateTime date;
  final double price;
  final int investorCount;
  final double portfolioSize;

  const FundFlowPoint({
    required this.date,
    required this.price,
    required this.investorCount,
    required this.portfolioSize,
  });

  factory FundFlowPoint.fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date']?.toString() ?? '');

    if (date == null) {
      throw const FormatException('Gecersiz fon akis tarihi.');
    }

    return FundFlowPoint(
      date: date,
      price: _toDouble(json['price']) ?? 0,
      investorCount: _toInt(json['investorCount']) ?? 0,
      portfolioSize: _toDouble(json['portfolioSize']) ?? 0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class FundFlowMetrics {
  final double? priceReturnPct;
  final double? portfolioChangePct;
  final double? investorChangePct;
  final double? estimatedNetFlow;
  final double? estimatedNetFlowPct;
  final String flowDirection;
  final int flowScore;

  const FundFlowMetrics({
    required this.priceReturnPct,
    required this.portfolioChangePct,
    required this.investorChangePct,
    required this.estimatedNetFlow,
    required this.estimatedNetFlowPct,
    required this.flowDirection,
    required this.flowScore,
  });

  factory FundFlowMetrics.fromJson(Map<String, dynamic> json) {
    return FundFlowMetrics(
      priceReturnPct: _toDouble(json['priceReturnPct']),
      portfolioChangePct: _toDouble(json['portfolioChangePct']),
      investorChangePct: _toDouble(json['investorChangePct']),
      estimatedNetFlow: _toDouble(json['estimatedNetFlow']),
      estimatedNetFlowPct: _toDouble(json['estimatedNetFlowPct']),
      flowDirection: json['flowDirection']?.toString().trim().isNotEmpty == true
          ? json['flowDirection'].toString().trim()
          : 'VERI YETERSIZ',
      flowScore: _toInt(json['flowScore']) ?? 0,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class FundFlowResult {
  final String fundCode;
  final String? fundName;
  final int periodMonths;
  final FundFlowPoint? start;
  final FundFlowPoint? end;
  final FundFlowMetrics? metrics;
  final bool available;
  final String provider;
  final String status;
  final DateTime updatedAt;

  const FundFlowResult({
    required this.fundCode,
    required this.fundName,
    required this.periodMonths,
    required this.start,
    required this.end,
    required this.metrics,
    required this.available,
    required this.provider,
    required this.status,
    required this.updatedAt,
  });

  factory FundFlowResult.fromJson(Map<String, dynamic> json) {
    final startRaw = json['start'];
    final endRaw = json['end'];
    final metricsRaw = json['metrics'];

    return FundFlowResult(
      fundCode: json['fundCode']?.toString().trim().toUpperCase() ?? '',
      fundName: json['fundName']?.toString().trim(),
      periodMonths: _toInt(json['periodMonths']) ?? 1,
      start: startRaw is Map
          ? FundFlowPoint.fromJson(Map<String, dynamic>.from(startRaw))
          : null,
      end: endRaw is Map
          ? FundFlowPoint.fromJson(Map<String, dynamic>.from(endRaw))
          : null,
      metrics: metricsRaw is Map
          ? FundFlowMetrics.fromJson(Map<String, dynamic>.from(metricsRaw))
          : null,
      available: json['available'] == true,
      provider: json['provider']?.toString().trim().isNotEmpty == true
          ? json['provider'].toString().trim()
          : 'TEFAS',
      status: json['status']?.toString().trim().isNotEmpty == true
          ? json['status'].toString().trim()
          : 'GERCEK TEFAS FON AKISI',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  factory FundFlowResult.unavailable({
    required String fundCode,
    required int periodMonths,
    required String status,
  }) {
    return FundFlowResult(
      fundCode: fundCode,
      fundName: null,
      periodMonths: periodMonths,
      start: null,
      end: null,
      metrics: null,
      available: false,
      provider: 'CROC FUND GATEWAY / TEFAS',
      status: status,
      updatedAt: DateTime.now(),
    );
  }
}
