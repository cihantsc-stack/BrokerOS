import '../models/learning_prediction_record.dart';
import 'learning_repository.dart';

class MemoryLearningRepository implements LearningRepository {
  final Map<String, List<LearningPredictionRecord>> _records =
      <String, List<LearningPredictionRecord>>{};

  @override
  List<LearningPredictionRecord> recordsFor(String symbol) {
    return List<LearningPredictionRecord>.unmodifiable(
      _records[symbol.toUpperCase()] ?? const <LearningPredictionRecord>[],
    );
  }

  @override
  void save(LearningPredictionRecord record) {
    final String key = record.symbol.toUpperCase();
    final List<LearningPredictionRecord> bucket = _records.putIfAbsent(
      key,
      () => <LearningPredictionRecord>[],
    );

    final bool alreadyExists = bucket.any(
      (LearningPredictionRecord item) =>
          item.decision == record.decision && item.score == record.score,
    );

    if (!alreadyExists) {
      bucket.insert(0, record);
    }
  }
}
