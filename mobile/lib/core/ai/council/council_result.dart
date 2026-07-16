import 'council_vote.dart';

class CouncilResult {
  final String finalDecision;
  final int confidence;
  final int buyVotes;
  final int waitVotes;
  final int sellVotes;
  final String strongestEngine;
  final String conflictSummary;
  final List<CouncilVote> votes;

  const CouncilResult({
    required this.finalDecision,
    required this.confidence,
    required this.buyVotes,
    required this.waitVotes,
    required this.sellVotes,
    required this.strongestEngine,
    required this.conflictSummary,
    required this.votes,
  });
}
