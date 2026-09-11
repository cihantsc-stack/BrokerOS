class RiskRewardSnapshot {
  final String symbol;
  final double riskScore;
  final double rewardScore;
  final double ratio;
  final double stopPercent;
  final double firstTargetPercent;
  final double secondTargetPercent;
  final String strategy;
  final String aiComment;

  const RiskRewardSnapshot({
    required this.symbol,
    required this.riskScore,
    required this.rewardScore,
    required this.ratio,
    required this.stopPercent,
    required this.firstTargetPercent,
    required this.secondTargetPercent,
    required this.strategy,
    required this.aiComment,
  });
}
