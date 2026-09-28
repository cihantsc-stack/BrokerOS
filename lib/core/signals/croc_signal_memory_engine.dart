/// Immutable signal snapshot and forward-only outcome evaluation.
///
/// The engine never rewrites the signal's original score, price or timestamp.
/// Callers must provide observations collected after the signal was created.
enum CrocSignalHorizon { minutes5, minutes15, hour1, sessionClose }

class CrocSignalSnapshot {
  final String id;
  final String symbol;
  final String engine;
  final DateTime createdAt;
  final double entryPrice;
  final int score;
  final double? targetPrice;
  final double? stopPrice;

  const CrocSignalSnapshot({
    required this.id,
    required this.symbol,
    required this.engine,
    required this.createdAt,
    required this.entryPrice,
    required this.score,
    this.targetPrice,
    this.stopPrice,
  });
}

class CrocSignalObservation {
  final DateTime observedAt;
  final double high;
  final double low;
  final double close;

  const CrocSignalObservation({
    required this.observedAt,
    required this.high,
    required this.low,
    required this.close,
  });
}

class CrocSignalOutcome {
  final CrocSignalHorizon horizon;
  final DateTime evaluatedAt;
  final double closePrice;
  final double returnPercent;
  final double maxFavorablePercent;
  final double maxAdversePercent;
  final bool targetTouched;
  final bool stopTouched;

  const CrocSignalOutcome({
    required this.horizon,
    required this.evaluatedAt,
    required this.closePrice,
    required this.returnPercent,
    required this.maxFavorablePercent,
    required this.maxAdversePercent,
    required this.targetTouched,
    required this.stopTouched,
  });
}

class CrocSignalMemoryEngine {
  const CrocSignalMemoryEngine();

  /// Null means that no observation exists at the requested horizon.
  /// For sessionClose, pass only observations from the signal's session
  /// and mark the last one as the confirmed closing observation.
  CrocSignalOutcome? evaluate(
    CrocSignalSnapshot signal,
    Iterable<CrocSignalObservation> observations, {
    required CrocSignalHorizon horizon,
    bool sessionClosed = false,
  }) {
    if (signal.entryPrice <= 0 || !signal.entryPrice.isFinite) return null;
    if (horizon == CrocSignalHorizon.sessionClose && !sessionClosed) {
      return null;
    }

    final end = switch (horizon) {
      CrocSignalHorizon.minutes5 =>
        signal.createdAt.add(const Duration(minutes: 5)),
      CrocSignalHorizon.minutes15 =>
        signal.createdAt.add(const Duration(minutes: 15)),
      CrocSignalHorizon.hour1 =>
        signal.createdAt.add(const Duration(hours: 1)),
      CrocSignalHorizon.sessionClose => null,
    };

    final valid = observations.where((o) {
      if (!o.observedAt.isAfter(signal.createdAt)) return false;
      if (!o.high.isFinite || !o.low.isFinite || !o.close.isFinite) {
        return false;
      }
      return o.low > 0 &&
          o.high >= o.low &&
          o.close >= o.low &&
          o.close <= o.high;
    }).toList()
      ..sort((a, b) => a.observedAt.compareTo(b.observedAt));

    if (valid.isEmpty) return null;

    // Sparse scanner observations rarely land on the exact horizon.
    // Select the first observation at/after the cutoff, with a maximum
    // 5-minute delay. Never use a pre-horizon quote as the final result.
    final CrocSignalObservation last;
    if (end == null) {
      last = valid.last;
    } else {
      final candidates = valid.where(
        (o) =>
            !o.observedAt.isBefore(end) &&
            !o.observedAt.isAfter(end.add(const Duration(minutes: 5))),
      );
      if (candidates.isEmpty) return null;
      last = candidates.first;
    }
    final eligible = valid
        .where((o) => !o.observedAt.isAfter(last.observedAt))
        .toList();

    final peak = eligible.map((o) => o.high).reduce(
      (a, b) => a > b ? a : b,
    );
    final trough = eligible.map((o) => o.low).reduce(
      (a, b) => a < b ? a : b,
    );
    final base = signal.entryPrice;

    return CrocSignalOutcome(
      horizon: horizon,
      evaluatedAt: last.observedAt,
      closePrice: last.close,
      returnPercent: (last.close / base - 1) * 100,
      maxFavorablePercent: (peak / base - 1) * 100,
      maxAdversePercent: (trough / base - 1) * 100,
      targetTouched: signal.targetPrice != null &&
          peak >= signal.targetPrice!,
      stopTouched: signal.stopPrice != null &&
          trough <= signal.stopPrice!,
    );
  }
}
