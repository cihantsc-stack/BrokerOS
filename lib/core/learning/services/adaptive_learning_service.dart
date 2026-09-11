import '../../decision/models/croc_decision_result.dart';
import '../../models/stock_analysis.dart';
import '../engines/adaptive_learning_engine.dart';
import '../models/adaptive_learning_profile.dart';
import '../models/learning_prediction_record.dart';
import '../repositories/memory_learning_repository.dart';

class AdaptiveLearningService {
  AdaptiveLearningService._();

  static final AdaptiveLearningService instance = AdaptiveLearningService._();

  final MemoryLearningRepository _repository = MemoryLearningRepository();

  AdaptiveLearningProfile profileFor({
    required StockAnalysis stock,
    required CrocDecisionResult decision,
  }) {
    _seedRecord(stock, decision);

    return const AdaptiveLearningEngine().buildProfile(
      stock: stock,
      decision: decision,
      records: _repository.recordsFor(stock.symbol),
    );
  }

  void _seedRecord(StockAnalysis stock, CrocDecisionResult decision) {
    final int seed = stock.symbol.codeUnits.fold<int>(
      0,
      (int total, int item) => total + item,
    );

    final double simulatedReturn = (((seed + decision.score) % 135) - 35) / 10;

    _repository.save(
      LearningPredictionRecord(
        symbol: stock.symbol,
        decision: decision.decision,
        score: decision.score,
        simulatedReturn: simulatedReturn,
        successful: simulatedReturn > 0,
        holdingDays: 2 + (seed % 8),
        createdAt: DateTime.now(),
      ),
    );
  }
}
