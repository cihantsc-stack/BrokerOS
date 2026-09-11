enum DecisionOutcome { pending, successful, unsuccessful }

extension DecisionOutcomeLabel on DecisionOutcome {
  String get label {
    switch (this) {
      case DecisionOutcome.pending:
        return 'BEKLEMEDE';
      case DecisionOutcome.successful:
        return 'DOĞRU';
      case DecisionOutcome.unsuccessful:
        return 'YANLIŞ';
    }
  }
}

class DecisionOutcomeRecord {
  final String decisionId;
  final String symbol;
  final String signalLabel;
  final double startPrice;
  final double endPrice;
  final double returnPercent;
  final DecisionOutcome outcome;
  final DateTime decisionTime;

  const DecisionOutcomeRecord({
    required this.decisionId,
    required this.symbol,
    required this.signalLabel,
    required this.startPrice,
    required this.endPrice,
    required this.returnPercent,
    required this.outcome,
    required this.decisionTime,
  });
}
