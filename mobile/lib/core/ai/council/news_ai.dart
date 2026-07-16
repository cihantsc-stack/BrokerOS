import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class NewsAi {
  const NewsAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = stock.newsScore.clamp(0, 100);

    if (score >= 90) {
      return CouncilVote(
        engine: 'Haber AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Haber akışı karar kalitesini pozitif destekliyor.',
      );
    }

    if (score >= 82) {
      return CouncilVote(
        engine: 'Haber AI',
        decision: 'AL',
        score: score,
        reason: 'Haber akışı karar kalitesini pozitif destekliyor.',
      );
    }

    if (score >= 55) {
      return CouncilVote(
        engine: 'Haber AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Haber etkisi nötr; ek teyit gerekli.',
      );
    }

    return CouncilVote(
      engine: 'Haber AI',
      decision: 'SAT',
      score: score,
      reason: 'Olumsuz haber etkisi risk yaratıyor.',
    );
  }
}
