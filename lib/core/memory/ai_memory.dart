import 'confidence_history.dart';
import 'decision_history.dart';
import 'memory_snapshot.dart';

class AiMemory {
  final String symbol;
  final List<MemorySnapshot> snapshots;

  const AiMemory({required this.symbol, required this.snapshots});

  DecisionHistory get decisionHistory => DecisionHistory(snapshots);

  ConfidenceHistory get confidenceHistory => ConfidenceHistory(snapshots);

  MemorySnapshot? get latest => snapshots.isEmpty ? null : snapshots.last;

  int get stability {
    if (snapshots.length <= 1) return 100;

    final changes = decisionHistory.changeCount;
    final possibleChanges = snapshots.length - 1;
    final score = 100 - ((changes / possibleChanges) * 100).round();

    return score.clamp(0, 100);
  }
}
