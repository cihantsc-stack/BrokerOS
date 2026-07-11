class StockAnalysis {
  final String symbol;

  final String company;

  final int aiScore;

  final String decision;

  final double entry;

  final double target1;

  final double target2;

  final double stop;

  final int confidence;

  final String risk;

  final List<String> reasons;

  const StockAnalysis({
    required this.symbol,
    required this.company,
    required this.aiScore,
    required this.decision,
    required this.entry,
    required this.target1,
    required this.target2,
    required this.stop,
    required this.confidence,
    required this.risk,
    required this.reasons,
  });
}