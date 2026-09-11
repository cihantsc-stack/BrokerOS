class RiskModel {
  final double volatility;
  final double marketRisk;
  final double liquidityRisk;

  const RiskModel({
    required this.volatility,
    required this.marketRisk,
    required this.liquidityRisk,
  });

  double get total => (volatility + marketRisk + liquidityRisk) / 3;
}
