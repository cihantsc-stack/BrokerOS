import 'memory_snapshot.dart';

class DecisionHistory {
  final List<MemorySnapshot> snapshots;

  const DecisionHistory(this.snapshots);

  List<MemorySnapshot> get changes {
    if (snapshots.length < 2) return snapshots;

    final result = <MemorySnapshot>[snapshots.first];

    for (int index = 1; index < snapshots.length; index++) {
      if (snapshots[index].decision != snapshots[index - 1].decision) {
        result.add(snapshots[index]);
      }
    }

    return List<MemorySnapshot>.unmodifiable(result);
  }

  String? get latestDecision =>
      snapshots.isEmpty ? null : snapshots.last.decision;

  int get changeCount => changes.length > 1 ? changes.length - 1 : 0;
}
