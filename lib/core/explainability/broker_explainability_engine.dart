import '../ai/council/council_result.dart';
import '../models/stock_analysis.dart';
import 'explainability_item.dart';
import 'explainability_report.dart';
import 'score_change.dart';

class BrokerExplainabilityEngine {
  const BrokerExplainabilityEngine._();

  static ExplainabilityReport analyze({
    required StockAnalysis stock,
    required CouncilResult council,
  }) {
    final items = <ExplainabilityItem>[
      _item(
        factor: 'Smart Money',
        score: stock.smartMoneyScore,
        weight: 0.24,
        baseline: 72,
        explanation: 'Kurumsal para ve büyük oyuncu hareketleri.',
      ),
      _item(
        factor: 'Teknik',
        score: stock.technicalScore,
        weight: 0.20,
        baseline: 74,
        explanation: 'Trend, ortalamalar ve teknik yapı.',
      ),
      _item(
        factor: 'Momentum',
        score: stock.momentumScore,
        weight: 0.16,
        baseline: 76,
        explanation: 'Fiyat hareketinin gücü ve devamlılığı.',
      ),
      _item(
        factor: 'Risk',
        score: stock.riskScore,
        weight: 0.16,
        baseline: 70,
        explanation: 'Volatilite, stop mesafesi ve risk kalitesi.',
      ),
      _item(
        factor: 'Game Theory',
        score:
            ((stock.smartMoneyScore * 0.40) +
                    (stock.institutionalScore * 0.35) +
                    (stock.momentumScore * 0.25))
                .round(),
        weight: 0.14,
        baseline: 73,
        explanation: 'Büyük oyuncuların olası davranış senaryosu.',
      ),
      _item(
        factor: 'Haber',
        score: stock.newsScore,
        weight: 0.10,
        baseline: 75,
        explanation: 'Haber akışının karar üzerindeki etkisi.',
      ),
    ];

    final sorted = List<ExplainabilityItem>.from(items)
      ..sort((a, b) => b.contribution.compareTo(a.contribution));

    final dominant = sorted.first.factor;

    return ExplainabilityReport(
      finalDecision: council.finalDecision,
      totalScore: council.confidence,
      dominantFactor: dominant,
      summary: _summary(
        decision: council.finalDecision,
        dominantFactor: dominant,
        items: items,
      ),
      items: List<ExplainabilityItem>.unmodifiable(items),
    );
  }

  static ExplainabilityItem _item({
    required String factor,
    required int score,
    required double weight,
    required int baseline,
    required String explanation,
  }) {
    final safeScore = score.clamp(0, 100);
    final contribution = (safeScore * weight).round();

    return ExplainabilityItem(
      factor: factor,
      score: safeScore,
      weight: weight,
      contribution: contribution,
      change: ScoreChange(previous: baseline, current: safeScore),
      explanation: explanation,
    );
  }

  static String _summary({
    required String decision,
    required String dominantFactor,
    required List<ExplainabilityItem> items,
  }) {
    final positive = items.where((item) => item.change.delta > 0).length;
    final negative = items.where((item) => item.change.delta < 0).length;

    if (decision.contains('AL')) {
      return '$dominantFactor kararı en güçlü destekleyen faktör. '
          '$positive faktör pozitif katkı üretirken '
          '$negative faktör sınırlayıcı kaldı.';
    }

    if (decision.contains('SAT')) {
      return '$dominantFactor karar üzerinde belirleyici olsa da '
          'toplam risk dengesi satış tarafını güçlendirdi.';
    }

    return '$dominantFactor öne çıkıyor ancak faktörler arasında '
        'yeterli ortak yön oluşmadı.';
  }
}
