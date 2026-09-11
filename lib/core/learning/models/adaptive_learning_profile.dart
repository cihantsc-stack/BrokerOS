import 'learning_module_weight.dart';
import 'learning_prediction_record.dart';

class AdaptiveLearningProfile {
  final String symbol;
  final int totalPredictions;
  final int successfulPredictions;
  final int failedPredictions;
  final int successRate;
  final int similarPatternSuccessRate;
  final String strongestModule;
  final String weakestModule;
  final String bestHoldingPeriod;
  final String learningStatus;
  final List<LearningModuleWeight> moduleWeights;
  final List<LearningPredictionRecord> recentRecords;
  final List<String> learnedInsights;

  const AdaptiveLearningProfile({
    required this.symbol,
    required this.totalPredictions,
    required this.successfulPredictions,
    required this.failedPredictions,
    required this.successRate,
    required this.similarPatternSuccessRate,
    required this.strongestModule,
    required this.weakestModule,
    required this.bestHoldingPeriod,
    required this.learningStatus,
    required this.moduleWeights,
    required this.recentRecords,
    required this.learnedInsights,
  });
}
