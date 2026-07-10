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

  final double? lastPrice;
  final double? dailyChange;
  final double? volume;

  final String? firstInstitution;
  final String? secondInstitution;
  final String? thirdInstitution;
  final double? smartMoneyFlow;

  // Broker Consensus Engine
  final int technicalScore;
  final int smartMoneyScore;
  final int institutionalScore;
  final int newsScore;
  final int riskScore;
  final int momentumScore;

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
    this.lastPrice,
    this.dailyChange,
    this.volume,
    this.firstInstitution,
    this.secondInstitution,
    this.thirdInstitution,
    this.smartMoneyFlow,
    this.technicalScore = 0,
    this.smartMoneyScore = 0,
    this.institutionalScore = 0,
    this.newsScore = 0,
    this.riskScore = 0,
    this.momentumScore = 0,
  });

  int get brokerConsensus {
    if (technicalScore == 0 &&
        smartMoneyScore == 0 &&
        institutionalScore == 0 &&
        newsScore == 0 &&
        riskScore == 0 &&
        momentumScore == 0) {
      return aiScore;
    }

    final total = technicalScore +
        smartMoneyScore +
        institutionalScore +
        newsScore +
        riskScore +
        momentumScore;

    return (total / 6).round().clamp(0, 100);
  }
}