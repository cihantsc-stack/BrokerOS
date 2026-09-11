import 'decision_vote.dart';

class CrocDecisionResult {
  final String symbol;
  final String decision;
  final int score;
  final int confidence;
  final int successProbability;
  final String risk;
  final String tradeWindow;
  final double entry;
  final double target;
  final double stop;
  final double riskReward;
  final List<DecisionVote> votes;
  final List<String> reasons;
  final List<String> warnings;
  final String narrative;
  final String invalidation;

  const CrocDecisionResult({
    required this.symbol,
    required this.decision,
    required this.score,
    required this.confidence,
    required this.successProbability,
    required this.risk,
    required this.tradeWindow,
    required this.entry,
    required this.target,
    required this.stop,
    required this.riskReward,
    required this.votes,
    required this.reasons,
    required this.warnings,
    required this.narrative,
    required this.invalidation,
  });

  int get positiveVoteCount =>
      votes.where((DecisionVote item) => item.isPositive).length;

  int get totalVoteCount => votes.length;
}
