class RadarOpportunity {
  final String symbol;
  final String company;
  final int score;
  final int confidence;
  final String decision;
  final String risk;
  final String tradeWindow;
  final double entry;
  final double target;
  final double stop;
  final List<String> reasons;

  const RadarOpportunity({
    required this.symbol,
    required this.company,
    required this.score,
    required this.confidence,
    required this.decision,
    required this.risk,
    required this.tradeWindow,
    required this.entry,
    required this.target,
    required this.stop,
    required this.reasons,
  });

  double get riskReward {
    final double riskAmount = (entry - stop).abs();

    if (riskAmount == 0) {
      return 0;
    }

    return (target - entry).abs() / riskAmount;
  }
}
