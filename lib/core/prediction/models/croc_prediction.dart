import 'prediction_horizon.dart';
import 'prediction_snapshot.dart';

class CrocPrediction {
  final String symbol;
  final PredictionHorizon horizon;
  final int modelProbability;
  final int confidence;
  final int riskScore;
  final String direction;
  final String regime;
  final bool shadowMode;
  final List<String> positiveFactors;
  final List<String> negativeFactors;
  final PredictionSnapshot snapshot;

  const CrocPrediction({
    required this.symbol,
    required this.horizon,
    required this.modelProbability,
    required this.confidence,
    required this.riskScore,
    required this.direction,
    required this.regime,
    required this.shadowMode,
    required this.positiveFactors,
    required this.negativeFactors,
    required this.snapshot,
  });

  String get probabilityLabel => 'Model olasılığı %$modelProbability';
}
