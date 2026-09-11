class AnalysisResult {
  final String symbol;
  final String name;
  final String assetType;

  final String decision;
  final int aiScore;
  final int confidence;
  final String risk;

  final double entry;
  final double stop;
  final List<double> targets;

  final List<String> whyBuy;
  final List<String> whyNotBuy;
  final String changeMyMind;

  final Map<String, int> brokerDna;
  final String gameTheory;
  final String finalComment;

  const AnalysisResult({
    required this.symbol,
    required this.name,
    required this.assetType,
    required this.decision,
    required this.aiScore,
    required this.confidence,
    required this.risk,
    required this.entry,
    required this.stop,
    required this.targets,
    required this.whyBuy,
    required this.whyNotBuy,
    required this.changeMyMind,
    required this.brokerDna,
    required this.gameTheory,
    required this.finalComment,
  });
}
