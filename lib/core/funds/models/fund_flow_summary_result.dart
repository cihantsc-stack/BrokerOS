class FundFlowSummaryResult {
  final String fundCode;
  final String? fundName;
  final double score;
  final String direction;
  final String trendLabel;
  final bool available;
  final String provider;
  final String status;
  final DateTime updatedAt;

  const FundFlowSummaryResult({
    required this.fundCode,
    required this.fundName,
    required this.score,
    required this.direction,
    required this.trendLabel,
    required this.available,
    required this.provider,
    required this.status,
    required this.updatedAt,
  });

  factory FundFlowSummaryResult.fromJson(Map<String, dynamic> json) {
    return FundFlowSummaryResult(
      fundCode: json['fundCode']?.toString().trim().toUpperCase() ?? '',
      fundName: json['fundName']?.toString().trim(),
      score: _toDouble(json['score']) ?? 0,
      direction: json['direction']?.toString().trim().isNotEmpty == true
          ? json['direction'].toString().trim()
          : 'VERI YETERSIZ',
      trendLabel: json['trendLabel']?.toString().trim().isNotEmpty == true
          ? json['trendLabel'].toString().trim()
          : 'VERI YETERSIZ',
      available: json['available'] == true,
      provider: json['provider']?.toString().trim().isNotEmpty == true
          ? json['provider'].toString().trim()
          : 'TEFAS',
      status: json['status']?.toString().trim().isNotEmpty == true
          ? json['status'].toString().trim()
          : 'CROC FUND FLOW SUMMARY',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory FundFlowSummaryResult.unavailable({
    required String fundCode,
    required String status,
  }) {
    return FundFlowSummaryResult(
      fundCode: fundCode,
      fundName: null,
      score: 0,
      direction: 'VERI YETERSIZ',
      trendLabel: 'VERI YETERSIZ',
      available: false,
      provider: 'CROC FUND GATEWAY / TEFAS',
      status: status,
      updatedAt: DateTime.now(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
