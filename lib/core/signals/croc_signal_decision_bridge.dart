import 'croc_signal_memory_engine.dart';
import 'croc_signal_memory_ledger.dart';

/// Read-only bridge between signal scoring, target/stop planning and memory.
/// A scanner candidate is not a trade, and missing levels stay unknown.
class CrocSignalDecisionBridge {
  const CrocSignalDecisionBridge();

  CrocSignalDecisionView? inspect(
    CrocSignalMemoryLedger ledger,
    String signalId,
  ) {
    final signal = ledger.signal(signalId);
    if (signal == null) return null;
    final entry = signal.entryPrice;
    final stop = signal.stopPrice;
    final target = signal.targetPrice;
    final risk = stop != null && stop.isFinite && stop > 0 && stop < entry
        ? (entry - stop) / entry * 100
        : null;
    final reward = target != null && target.isFinite && target > entry
        ? (target - entry) / entry * 100
        : null;
    return CrocSignalDecisionView(
      signal: signal,
      riskPercent: risk,
      rewardPercent: reward,
      rewardRiskRatio: risk != null && reward != null && risk > 0
          ? reward / risk
          : null,
      minutes5: ledger.outcome(signalId, CrocSignalHorizon.minutes5),
      minutes15: ledger.outcome(signalId, CrocSignalHorizon.minutes15),
      hour1: ledger.outcome(signalId, CrocSignalHorizon.hour1),
    );
  }
}

class CrocSignalDecisionView {
  final CrocSignalSnapshot signal;
  final double? riskPercent;
  final double? rewardPercent;
  final double? rewardRiskRatio;
  final CrocSignalOutcome? minutes5;
  final CrocSignalOutcome? minutes15;
  final CrocSignalOutcome? hour1;

  const CrocSignalDecisionView({
    required this.signal,
    required this.riskPercent,
    required this.rewardPercent,
    required this.rewardRiskRatio,
    required this.minutes5,
    required this.minutes15,
    required this.hour1,
  });
}
