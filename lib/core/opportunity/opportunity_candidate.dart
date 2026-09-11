class OpportunityCandidate {
  final String symbol;
  final double score;
  final String reason;
  final bool isCurrent;

  const OpportunityCandidate({
    required this.symbol,
    required this.score,
    required this.reason,
    required this.isCurrent,
  });
}
