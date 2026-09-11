import '../../models/stock_analysis.dart';
import 'council_vote.dart';

class MomentumAi {
  const MomentumAi._();

  static CouncilVote evaluate(StockAnalysis stock) {
    final score = stock.momentumScore.clamp(0, 100);

    if (score >= 85) {
      return CouncilVote(
        engine: 'Momentum AI',
        decision: 'GÜÇLÜ AL',
        score: score,
        reason: 'Momentum güçlü ve alıcılar kontrolü sürdürüyor.',
      );
    }

    if (score >= 68) {
      return CouncilVote(
        engine: 'Momentum AI',
        decision: 'AL',
        score: score,
        reason: 'Momentum pozitif ve yükseliş tarafını destekliyor.',
      );
    }

    if (score >= 50) {
      return CouncilVote(
        engine: 'Momentum AI',
        decision: 'BEKLE',
        score: score,
        reason: 'Momentum sınırlı; fiyat kovalanmamalı.',
      );
    }

    return CouncilVote(
      engine: 'Momentum AI',
      decision: 'SAT',
      score: score,
      reason: 'Momentum zayıf ve satış baskısı riski var.',
    );
  }
}
