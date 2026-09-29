import 'croc_signal_memory_engine.dart';
import 'croc_signal_exit_tracker.dart';

/// Session-scoped, in-memory signal ledger. No network or disk side effects.
///
/// One immutable entry per signal ID. Subsequent observations can be supplied
/// independently; duplicate observations at the same timestamp are ignored.
/// Persistence and market-feed wiring are deliberately separate concerns.
class CrocSignalMemoryLedger {
  final Map<String, CrocSignalSnapshot> _signals = {};
  final Map<String, Map<DateTime, CrocSignalObservation>> _observations = {};
  final CrocSignalMemoryEngine _engine = const CrocSignalMemoryEngine();
  final CrocSignalExitTracker _exitTracker = const CrocSignalExitTracker();

  int get signalCount => _signals.length;

  /// Removes expired signal snapshots and their observations.
  int pruneBefore(DateTime cutoff) {
    final expiredIds = _signals.entries
        .where((entry) => entry.value.createdAt.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList();
    for (final id in expiredIds) {
      _signals.remove(id);
      _observations.remove(id);
    }
    return expiredIds.length;
  }

  bool recordSignal(CrocSignalSnapshot signal) {
    if (signal.id.isEmpty ||
        signal.symbol.isEmpty ||
        signal.entryPrice <= 0 ||
        !signal.entryPrice.isFinite ||
        _signals.containsKey(signal.id)) {
      return false;
    }
    _signals[signal.id] = signal;
    _observations[signal.id] = {};
    return true;
  }

  bool recordObservation(String signalId, CrocSignalObservation observation) {
    final signal = _signals[signalId];
    if (signal == null || !observation.observedAt.isAfter(signal.createdAt)) {
      return false;
    }
    if (!observation.high.isFinite ||
        !observation.low.isFinite ||
        !observation.close.isFinite ||
        observation.low <= 0 ||
        observation.high < observation.low ||
        observation.close < observation.low ||
        observation.close > observation.high) {
      return false;
    }
    final points = _observations[signalId]!;
    if (points.containsKey(observation.observedAt)) return false;
    points[observation.observedAt] = observation;
    return true;
  }

  CrocSignalOutcome? outcome(
    String signalId,
    CrocSignalHorizon horizon, {
    bool sessionClosed = false,
  }) {
    final signal = _signals[signalId];
    if (signal == null) return null;
    return _engine.evaluate(
      signal,
      _observations[signalId]!.values,
      horizon: horizon,
      sessionClosed: sessionClosed,
    );
  }

  /// The first observed target/stop event; same-bar collisions stay ambiguous.
  /// Returns null only for an unknown signal ID.
  CrocSignalExitEvent? firstExit(String signalId) {
    final signal = _signals[signalId];
    if (signal == null) return null;
    return _exitTracker.evaluate(signal, _observations[signalId]!.values);
  }

  CrocSignalSnapshot? signal(String signalId) => _signals[signalId];
}
