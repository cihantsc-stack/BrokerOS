import 'consensus_reason.dart';
import 'consensus_vote.dart';

class ConsensusResult {
  final String symbol;
  final ConsensusSignal finalSignal;
  final int confidence;
  final String riskLevel;
  final List<ConsensusVote> votes;
  final List<ConsensusReason> reasons;
  final DateTime createdAt;

  const ConsensusResult({
    required this.symbol,
    required this.finalSignal,
    required this.confidence,
    required this.riskLevel,
    required this.votes,
    required this.reasons,
    required this.createdAt,
  });
}
