import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class TechnicalAi {
  const TechnicalAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = stock.technicalScore.clamp(0, 100);

    if (score >= 85) {
      return CouncilVote(
        engine: 'Teknik AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Teknik göstergeler güçlü yükseliş teyidi veriyor.',
      );
    }

    if (score >= 70) {
      return CouncilVote(
        engine: 'Teknik AI',
        decision: 'AL',
        score: score,
        reason: 'Teknik görünüm pozitif ve alım tarafını destekliyor.',
      );
    }

    if (score >= 50) {
      return CouncilVote(
        engine: 'Teknik AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Teknik görünüm kararsız; yeni teyit beklenmeli.',
      );
    }

    return CouncilVote(
      engine: 'Teknik AI',
      decision: 'SAT',
      score: score,
      reason: 'Teknik yapı zayıf ve aşağı yönlü risk taşıyor.',
    );
  }
}
