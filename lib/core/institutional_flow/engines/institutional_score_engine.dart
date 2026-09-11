import '../models/broker_flow.dart';
import '../models/institutional_direction.dart';

class InstitutionalScoreResult {
  final double score;
  final InstitutionalDirection direction;

  const InstitutionalScoreResult({
    required this.score,
    required this.direction,
  });
}

class InstitutionalScoreEngine {
  const InstitutionalScoreEngine();

  InstitutionalScoreResult calculate({
    required List<BrokerFlow> brokers,
    required double foreignRatio,
    required double fundFlow,
    required double lotLockRatio,
    required double concentrationRatio,
  }) {
    final double brokerBalance = brokers.fold<double>(
      0,
      (double sum, BrokerFlow item) =>
          sum + (item.buyer ? item.marketShare : -item.marketShare),
    );

    double score = 50;
    score += brokerBalance * 0.65;
    score += (foreignRatio - 45) * 0.45;
    score += fundFlow * 2.8;
    score += (lotLockRatio - 50) * 0.35;
    score += (concentrationRatio - 50) * 0.20;

    score = score.clamp(0, 100).toDouble();

    final InstitutionalDirection direction;

    if (score >= 78) {
      direction = InstitutionalDirection.strongBuy;
    } else if (score >= 60) {
      direction = InstitutionalDirection.buy;
    } else if (score >= 42) {
      direction = InstitutionalDirection.neutral;
    } else if (score >= 24) {
      direction = InstitutionalDirection.sell;
    } else {
      direction = InstitutionalDirection.strongSell;
    }

    return InstitutionalScoreResult(score: score, direction: direction);
  }
}
