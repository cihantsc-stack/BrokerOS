class AiDecision {
  final String symbol;
  final String decision;
  final int score;
  final int confidence;
  final String risk;
  final String summary;
  final String strongestReason;
  final String biggestRisk;
  final List<String> todayMission;
  final List<String> watchList;
  final String nextTrigger;

  const AiDecision({
    required this.symbol,
    required this.decision,
    required this.score,
    required this.confidence,
    required this.risk,
    required this.summary,
    required this.strongestReason,
    required this.biggestRisk,
    required this.todayMission,
    required this.watchList,
    required this.nextTrigger,
  });
}
