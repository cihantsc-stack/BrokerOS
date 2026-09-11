import 'memory_snapshot.dart';

class ConfidenceHistory {
  final List<MemorySnapshot> snapshots;

  const ConfidenceHistory(this.snapshots);

  List<int> get values =>
      List<int>.unmodifiable(snapshots.map((item) => item.confidence));

  int get average {
    if (snapshots.isEmpty) return 0;

    final total = snapshots.fold<int>(0, (sum, item) => sum + item.confidence);

    return (total / snapshots.length).round();
  }

  int get min {
    if (snapshots.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  int get max {
    if (snapshots.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }
}
