enum ConsensusSignal { strongSell, sell, hold, buy, strongBuy }

extension ConsensusSignalLabel on ConsensusSignal {
  String get label {
    switch (this) {
      case ConsensusSignal.strongSell:
        return 'GÜÇLÜ SAT';
      case ConsensusSignal.sell:
        return 'SAT';
      case ConsensusSignal.hold:
        return 'BEKLE';
      case ConsensusSignal.buy:
        return 'AL';
      case ConsensusSignal.strongBuy:
        return 'GÜÇLÜ AL';
    }
  }

  double get numericValue {
    switch (this) {
      case ConsensusSignal.strongSell:
        return -2;
      case ConsensusSignal.sell:
        return -1;
      case ConsensusSignal.hold:
        return 0;
      case ConsensusSignal.buy:
        return 1;
      case ConsensusSignal.strongBuy:
        return 2;
    }
  }
}

class ConsensusVote {
  final String agent;
  final ConsensusSignal signal;
  final int confidence;
  final double weight;
  final String reason;

  const ConsensusVote({
    required this.agent,
    required this.signal,
    required this.confidence,
    required this.weight,
    required this.reason,
  });

  double get weightedScore => signal.numericValue * (confidence / 100) * weight;
}
