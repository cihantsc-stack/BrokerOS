import '../models/broker_consensus.dart';

class ConfidenceEngine {
  const ConfidenceEngine._();

  static int calculate(BrokerConsensus consensus) {
    final weightedScore =
        (consensus.technicalScore * 0.22) +
        (consensus.smartMoneyScore * 0.24) +
        (consensus.momentumScore * 0.18) +
        (consensus.newsScore * 0.12) +
        (consensus.gameTheoryScore * 0.14) +
        (consensus.riskScore * 0.10);

    final scoreSpread = _scoreSpread(consensus);

    final consistencyBonus = scoreSpread <= 12
        ? 6
        : scoreSpread <= 20
            ? 3
            : 0;

    final riskPenalty = consensus.riskScore < 50
        ? 10
        : consensus.riskScore < 65
            ? 5
            : 0;

    final confidence =
        weightedScore.round() + consistencyBonus - riskPenalty;

    return confidence.clamp(0, 100);
  }

  static int _scoreSpread(BrokerConsensus consensus) {
    final scores = <int>[
      consensus.technicalScore,
      consensus.smartMoneyScore,
      consensus.newsScore,
      consensus.momentumScore,
      consensus.riskScore,
      consensus.gameTheoryScore,
    ];

    scores.sort();

    return scores.last - scores.first;
  }
}