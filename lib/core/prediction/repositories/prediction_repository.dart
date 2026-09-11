import '../models/croc_prediction.dart';

abstract class PredictionRepository {
  List<CrocPrediction> predictionsFor(String symbol);
  void saveAll(List<CrocPrediction> predictions);
  void clear();
}
