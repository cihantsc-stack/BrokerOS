import 'decision_outcome.dart';

class DecisionStatistics {
  final int totalDecisions;
  final int evaluatedDecisions;
  final int successfulDecisions;
  final int unsuccessfulDecisions;
  final int pendingDecisions;
  final List<DecisionOutcomeRecord> records;

  const DecisionStatistics({
    required this.totalDecisions,
    required this.evaluatedDecisions,
    required this.successfulDecisions,
    required this.unsuccessfulDecisions,
    required this.pendingDecisions,
    required this.records,
  });

  double get accuracyPercent {
    if (evaluatedDecisions == 0) return 0;
    return (successfulDecisions / evaluatedDecisions) * 100;
  }

  bool get hasEvaluatedDecision => evaluatedDecisions > 0;
}
