enum DecisionVoteType { strongBuy, buy, neutral, wait, sell }

class DecisionVote {
  final String module;
  final DecisionVoteType vote;
  final int score;
  final String reason;

  const DecisionVote({
    required this.module,
    required this.vote,
    required this.score,
    required this.reason,
  });

  String get label {
    switch (vote) {
      case DecisionVoteType.strongBuy:
        return 'GÜÇLÜ AL';
      case DecisionVoteType.buy:
        return 'AL';
      case DecisionVoteType.neutral:
        return 'NÖTR';
      case DecisionVoteType.wait:
        return 'BEKLE';
      case DecisionVoteType.sell:
        return 'SAT';
    }
  }

  bool get isPositive =>
      vote == DecisionVoteType.strongBuy || vote == DecisionVoteType.buy;
}
