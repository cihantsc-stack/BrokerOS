class FundMetricsResult {
  final bool available;
  final String status;

  final double? return1M;
  final double? return3M;
  final double? return6M;
  final double? return1Y;

  final double? annualizedVolatility;
  final double? maxDrawdown;

  final String riskLevel;
  final int observationCount;

  const FundMetricsResult({
    required this.available,
    required this.status,
    required this.return1M,
    required this.return3M,
    required this.return6M,
    required this.return1Y,
    required this.annualizedVolatility,
    required this.maxDrawdown,
    required this.riskLevel,
    required this.observationCount,
  });

  const FundMetricsResult.dataWaiting({this.status = 'VERI BEKLENIYOR'})
    : available = false,
      return1M = null,
      return3M = null,
      return6M = null,
      return1Y = null,
      annualizedVolatility = null,
      maxDrawdown = null,
      riskLevel = 'VERI BEKLENIYOR',
      observationCount = 0;
}
