class BrokerConsensus {
  final int score;
  final String decision;

  final int technicalScore;
  final int smartMoneyScore;
  final int institutionScore;
  final int newsScore;
  final int momentumScore;
  final int riskScore;
  final int gameTheoryScore;

  final int confidence;

  final int buySignals;
  final int holdSignals;
  final int sellSignals;

  final double buyProbability;
  final double sellProbability;

  final String explanation;

  final List<String> positives;
  final List<String> negatives;

  const BrokerConsensus({
    required this.score,
    required this.decision,
    required this.technicalScore,
    required this.smartMoneyScore,
    required this.institutionScore,
    required this.newsScore,
    required this.momentumScore,
    required this.riskScore,
    required this.gameTheoryScore,
    required this.confidence,
    required this.buySignals,
    required this.holdSignals,
    required this.sellSignals,
    required this.buyProbability,
    required this.sellProbability,
    required this.explanation,
    required this.positives,
    required this.negatives,
  });
}