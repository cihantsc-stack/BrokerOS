import '../consensus/consensus_vote.dart';
import '../timeline/decision_snapshot.dart';
import 'decision_outcome.dart';
import 'decision_statistics.dart';

class DecisionAccuracyEngine {
  DecisionAccuracyEngine._();

  static final DecisionAccuracyEngine instance = DecisionAccuracyEngine._();

  DecisionStatistics evaluate(List<DecisionSnapshot> newestFirstHistory) {
    if (newestFirstHistory.isEmpty) {
      return const DecisionStatistics(
        totalDecisions: 0,
        evaluatedDecisions: 0,
        successfulDecisions: 0,
        unsuccessfulDecisions: 0,
        pendingDecisions: 0,
        records: <DecisionOutcomeRecord>[],
      );
    }

    final List<DecisionSnapshot> chronological = newestFirstHistory.reversed
        .toList();

    final List<DecisionOutcomeRecord> records = <DecisionOutcomeRecord>[];

    for (int index = 0; index < chronological.length; index++) {
      final DecisionSnapshot current = chronological[index];

      final bool isLastRecord = index == chronological.length - 1;

      if (isLastRecord) {
        records.add(
          DecisionOutcomeRecord(
            decisionId: current.id,
            symbol: current.symbol,
            signalLabel: current.signal.label,
            startPrice: current.price,
            endPrice: current.price,
            returnPercent: 0.0,
            outcome: DecisionOutcome.pending,
            decisionTime: current.createdAt,
          ),
        );

        continue;
      }

      final DecisionSnapshot next = chronological[index + 1];

      final double returnPercent = current.price == 0.0
          ? 0.0
          : (((next.price - current.price) / current.price) * 100).toDouble();

      final DecisionOutcome outcome = _classify(
        signal: current.signal,
        returnPercent: returnPercent,
      );

      records.add(
        DecisionOutcomeRecord(
          decisionId: current.id,
          symbol: current.symbol,
          signalLabel: current.signal.label,
          startPrice: current.price,
          endPrice: next.price,
          returnPercent: returnPercent,
          outcome: outcome,
          decisionTime: current.createdAt,
        ),
      );
    }

    final int successful = records
        .where(
          (DecisionOutcomeRecord item) =>
              item.outcome == DecisionOutcome.successful,
        )
        .length;

    final int unsuccessful = records
        .where(
          (DecisionOutcomeRecord item) =>
              item.outcome == DecisionOutcome.unsuccessful,
        )
        .length;

    final int pending = records
        .where(
          (DecisionOutcomeRecord item) =>
              item.outcome == DecisionOutcome.pending,
        )
        .length;

    return DecisionStatistics(
      totalDecisions: records.length,
      evaluatedDecisions: successful + unsuccessful,
      successfulDecisions: successful,
      unsuccessfulDecisions: unsuccessful,
      pendingDecisions: pending,
      records: records.reversed.toList(growable: false),
    );
  }

  DecisionOutcome _classify({
    required ConsensusSignal signal,
    required double returnPercent,
  }) {
    const double directionThreshold = 0.30;
    const double holdBand = 0.80;

    switch (signal) {
      case ConsensusSignal.strongBuy:
      case ConsensusSignal.buy:
        return returnPercent >= directionThreshold
            ? DecisionOutcome.successful
            : DecisionOutcome.unsuccessful;

      case ConsensusSignal.strongSell:
      case ConsensusSignal.sell:
        return returnPercent <= -directionThreshold
            ? DecisionOutcome.successful
            : DecisionOutcome.unsuccessful;

      case ConsensusSignal.hold:
        return returnPercent.abs() <= holdBand
            ? DecisionOutcome.successful
            : DecisionOutcome.unsuccessful;
    }
  }
}
