class BrokerConsensus {

  final int score;

  final String decision;

  final int buySignals;

  final int holdSignals;

  final int sellSignals;

  final List<String> positives;

  final List<String> negatives;

  const BrokerConsensus({

    required this.score,

    required this.decision,

    required this.buySignals,

    required this.holdSignals,

    required this.sellSignals,

    required this.positives,

    required this.negatives,

  });

}