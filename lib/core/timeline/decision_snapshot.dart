import '../consensus/consensus_vote.dart';

class DecisionSnapshot {
  final String id;
  final String symbol;
  final ConsensusSignal signal;
  final int confidence;
  final String riskLevel;
  final int technicalScore;
  final int newsScore;
  final int smartMoneyScore;
  final int fundScore;
  final double price;
  final double changePercent;
  final DateTime createdAt;

  const DecisionSnapshot({
    required this.id,
    required this.symbol,
    required this.signal,
    required this.confidence,
    required this.riskLevel,
    required this.technicalScore,
    required this.newsScore,
    required this.smartMoneyScore,
    required this.fundScore,
    required this.price,
    required this.changePercent,
    required this.createdAt,
  });
}
