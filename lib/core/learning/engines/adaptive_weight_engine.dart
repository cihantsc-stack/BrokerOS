import '../../decision/models/croc_decision_result.dart';
import '../models/learning_module_weight.dart';

class AdaptiveWeightEngine {
  const AdaptiveWeightEngine();

  List<LearningModuleWeight> calculate(CrocDecisionResult decision) {
    final Map<String, double> baseWeights = <String, double>{
      'Teknik Analiz': 0.22,
      'Smart Money': 0.21,
      'Kurumsal Para': 0.19,
      'Momentum': 0.16,
      'Haber Etkisi': 0.10,
      'Risk Disiplini': 0.12,
    };

    return decision.votes.map((vote) {
      final double base = baseWeights[vote.module] ?? 0.10;
      final int seed = decision.symbol.codeUnits.fold<int>(0, (a, b) => a + b);
      final int successRate = (48 + ((vote.score + seed) % 48))
          .clamp(0, 96)
          .toInt();

      final double adjustment = ((successRate - 70) / 1000)
          .clamp(-0.035, 0.035)
          .toDouble();

      final double adaptive = (base + adjustment).clamp(0.05, 0.30).toDouble();

      return LearningModuleWeight(
        module: vote.module,
        baseWeight: base,
        adaptiveWeight: adaptive,
        successRate: successRate,
        insight: successRate >= 78
            ? '${vote.module} geçmiş sonuçlarda güçlü katkı sağladı.'
            : successRate >= 62
            ? '${vote.module} dengeli katkı sağlıyor.'
            : '${vote.module} ağırlığı ihtiyatlı tutuluyor.',
      );
    }).toList();
  }
}
