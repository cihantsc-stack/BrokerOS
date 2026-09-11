class LearningPredictionRecord {
  final String symbol;
  final String decision;
  final int score;
  final double simulatedReturn;
  final bool successful;
  final int holdingDays;
  final DateTime createdAt;

  const LearningPredictionRecord({
    required this.symbol,
    required this.decision,
    required this.score,
    required this.simulatedReturn,
    required this.successful,
    required this.holdingDays,
    required this.createdAt,
  });
}
