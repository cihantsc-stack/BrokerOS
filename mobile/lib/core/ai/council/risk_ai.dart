import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class RiskAi {
  const RiskAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = stock.riskScore.clamp(0, 100);

    if (score >= 90) {
      return CouncilVote(
        engine: 'Risk AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Risk kalitesi güçlü; işlem planı uygulanabilir.',
      );
    }

    if (score >= 82) {
      return CouncilVote(
        engine: 'Risk AI',
        decision: 'AL',
        score: score,
        reason: 'Risk kalitesi güçlü; işlem planı uygulanabilir.',
      );
    }

    if (score >= 60) {
      return CouncilVote(
        engine: 'Risk AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Risk orta seviyede; stop disiplini şart.',
      );
    }

    return CouncilVote(
      engine: 'Risk AI',
      decision: 'SAT',
      score: score,
      reason: 'Risk seviyesi yüksek; yeni pozisyon önerilmiyor.',
    );
  }
}
