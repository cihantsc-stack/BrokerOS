import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class GameTheoryAi {
  const GameTheoryAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = ((stock.smartMoneyScore * 0.40) +
            (stock.institutionalScore * 0.35) +
            (stock.momentumScore * 0.25))
        .round()
        .clamp(0, 100);

    if (score >= 86) {
      return CouncilVote(
        engine: 'Game Theory AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Büyük oyuncuların pozisyon biriktirme olasılığı yüksek.',
      );
    }

    if (score >= 70) {
      return CouncilVote(
        engine: 'Game Theory AI',
        decision: 'AL',
        score: score,
        reason: 'Oyuncu davranışları alım senaryosunu destekliyor.',
      );
    }

    if (score >= 52) {
      return CouncilVote(
        engine: 'Game Theory AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Büyük oyuncu davranışı henüz net değil.',
      );
    }

    return CouncilVote(
      engine: 'Game Theory AI',
      decision: 'SAT',
      score: score,
      reason: 'Dağıtım ve satış baskısı olasılığı yükseliyor.',
    );
  }
}
