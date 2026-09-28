import 'croc_signal_memory_engine.dart';

/// A price bar cannot reveal whether target or stop traded first.
/// Ambiguous bars remain explicitly unresolved instead of claiming a win.
enum CrocSignalExitType {
  open,
  target,
  stop,
  ambiguous,
}

class CrocSignalExitEvent {
  final CrocSignalExitType type;
  final DateTime? occurredAt;
  final double? level;

  const CrocSignalExitEvent({
    required this.type,
    this.occurredAt,
    this.level,
  });
}

/// Stateless, forward-only first-exit evaluator for long-side signals.
/// A separate tick-level execution feed is required to resolve ambiguous bars.
class CrocSignalExitTracker {
  const CrocSignalExitTracker();

  CrocSignalExitEvent evaluate(
    CrocSignalSnapshot signal,
    Iterable<CrocSignalObservation> observations,
  ) {
    final target = signal.targetPrice;
    final stop = signal.stopPrice;
    if (target == null ||
        stop == null ||
        !target.isFinite ||
        !stop.isFinite ||
        !signal.entryPrice.isFinite ||
        signal.entryPrice <= 0 ||
        target <= signal.entryPrice ||
        stop >= signal.entryPrice ||
        stop <= 0) {
      return const CrocSignalExitEvent(type: CrocSignalExitType.open);
    }

    final sorted = observations
        .where(
          (o) =>
              o.observedAt.isAfter(signal.createdAt) &&
              o.high.isFinite &&
              o.low.isFinite &&
              o.close.isFinite &&
              o.low > 0 &&
              o.high >= o.low &&
              o.close >= o.low &&
              o.close <= o.high,
        )
        .toList()
      ..sort((a, b) => a.observedAt.compareTo(b.observedAt));

    for (final bar in sorted) {
      final hitTarget = bar.high >= target;
      final hitStop = bar.low <= stop;
      if (hitTarget && hitStop) {
        return CrocSignalExitEvent(
          type: CrocSignalExitType.ambiguous,
          occurredAt: bar.observedAt,
        );
      }
      if (hitTarget) {
        return CrocSignalExitEvent(
          type: CrocSignalExitType.target,
          occurredAt: bar.observedAt,
          level: target,
        );
      }
      if (hitStop) {
        return CrocSignalExitEvent(
          type: CrocSignalExitType.stop,
          occurredAt: bar.observedAt,
          level: stop,
        );
      }
    }

    return const CrocSignalExitEvent(type: CrocSignalExitType.open);
  }
}
