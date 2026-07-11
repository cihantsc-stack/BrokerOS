class BrokerVote {
  final String engine;
  final String decision;
  final int score;
  final String reason;

  const BrokerVote({
    required this.engine,
    required this.decision,
    required this.score,
    required this.reason,
  });
}
