import '../models/croc_prediction.dart';
import 'prediction_repository.dart';

class MemoryPredictionRepository implements PredictionRepository {
  final Map<String, List<CrocPrediction>> _records = {};

  @override
  List<CrocPrediction> predictionsFor(String symbol) =>
      List<CrocPrediction>.unmodifiable(
        _records[symbol.toUpperCase()] ?? const <CrocPrediction>[],
      );

  @override
  void saveAll(List<CrocPrediction> predictions) {
    if (predictions.isEmpty) return;
    final key = predictions.first.symbol.toUpperCase();
    final bucket = _records.putIfAbsent(key, () => []);
    for (final p in predictions) {
      final exists = bucket.any(
        (x) =>
            x.horizon == p.horizon &&
            x.snapshot.createdAt == p.snapshot.createdAt,
      );
      if (!exists) bucket.insert(0, p);
    }
  }

  @override
  void clear() => _records.clear();
}
