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
    final bool hasBrokerData = brokers.isNotEmpty;
    final bool hasForeignData = foreignRatio > 0;
    final bool hasFundData = fundFlow != 0;
    final bool hasLotLockData = lotLockRatio > 0;
    final bool hasConcentrationData = concentrationRatio > 0;

    final bool hasAnyRealData =
        hasBrokerData ||
        hasForeignData ||
        hasFundData ||
        hasLotLockData ||
        hasConcentrationData;

    if (!hasAnyRealData) {
      return const InstitutionalScoreResult(
        score: 0,
        direction: InstitutionalDirection.neutral,
      );
    }

    double weightedTotal = 0;
    double totalWeight = 0;

    if (hasBrokerData) {
      final double brokerBalance = brokers.fold<double>(
        0,
        (double sum, BrokerFlow item) =>
            sum + (item.buyer ? item.marketShare : -item.marketShare),
      );

      final double brokerScore = (50 + brokerBalance * 0.65)
          .clamp(0, 100)
          .toDouble();

      weightedTotal += brokerScore * 0.35;
      totalWeight += 0.35;
    }

    if (hasForeignData) {
      final double foreignScore = (50 + (foreignRatio - 45) * 0.9)
          .clamp(0, 100)
          .toDouble();

      weightedTotal += foreignScore * 0.20;
      totalWeight += 0.20;
    }

    if (hasFundData) {
      final double fundScore = (50 + fundFlow * 5).clamp(0, 100).toDouble();

      weightedTotal += fundScore * 0.20;
      totalWeight += 0.20;
    }

    if (hasLotLockData) {
      final double lotLockScore = lotLockRatio.clamp(0, 100).toDouble();

      weightedTotal += lotLockScore * 0.15;
      totalWeight += 0.15;
    }

    if (hasConcentrationData) {
      final double concentrationScore = concentrationRatio
          .clamp(0, 100)
          .toDouble();

      weightedTotal += concentrationScore * 0.10;
      totalWeight += 0.10;
    }

    final double score = totalWeight > 0 ? (weightedTotal / totalWeight) : 0;

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

    return InstitutionalScoreResult(
      score: score.clamp(0, 100).toDouble(),
      direction: direction,
    );
  }
}
