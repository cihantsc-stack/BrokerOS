import '../models/learning_prediction_record.dart';

abstract class LearningRepository {
  List<LearningPredictionRecord> recordsFor(String symbol);

  void save(LearningPredictionRecord record);
}
