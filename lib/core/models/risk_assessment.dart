class RiskAssessment {
  final int score;
  final String level;
  final List<String> reasons;

  const RiskAssessment({
    required this.score,
    required this.level,
    required this.reasons,
  });

  bool get isLowRisk => score >= 75;

  bool get isMediumRisk => score >= 50 && score < 75;

  bool get isHighRisk => score < 50;
}
