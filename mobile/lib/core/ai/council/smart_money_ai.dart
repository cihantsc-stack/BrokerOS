import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class SmartMoneyAi {
  const SmartMoneyAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = stock.smartMoneyScore.clamp(0, 100);

    if (score >= 88) {
      return CouncilVote(
        engine: 'Smart Money AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Kurumsal para güçlü biçimde alım yönünde.',
      );
    }

    if (score >= 70) {
      return CouncilVote(
        engine: 'Smart Money AI',
        decision: 'AL',
        score: score,
        reason: 'Büyük para akışı alım tarafını destekliyor.',
      );
    }

    if (score >= 50) {
      return CouncilVote(
        engine: 'Smart Money AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Kurumsal para dengeli; yön teyidi henüz yeterli değil.',
      );
    }

    return CouncilVote(
      engine: 'Smart Money AI',
      decision: 'SAT',
      score: score,
      reason: 'Kurumsal para çıkışı riski yükseltiyor.',
    );
  }
}
