import '../../models/stock_analysis.dart';
import 'council_result.dart';
import 'council_vote.dart';
import 'game_theory_ai.dart';
import 'momentum_ai.dart';
import 'news_ai.dart';
import 'risk_ai.dart';
import 'smart_money_ai.dart';
import 'technical_ai.dart';

class BrokerCouncilEngine {
  const BrokerCouncilEngine._();

  static CouncilResult evaluate(StockAnalysis stock) {
    final votes = <CouncilVote>[
      TechnicalAi.evaluate(stock),
      SmartMoneyAi.evaluate(stock),
      NewsAi.evaluate(stock),
      RiskAi.evaluate(stock),
      MomentumAi.evaluate(stock),
      GameTheoryAi.evaluate(stock),
    ];

    final buyVotes = votes.where(_isBuy).length;
    final waitVotes = votes.where((vote) => vote.decision == 'BEKLE').length;
    final sellVotes = votes.where((vote) => vote.decision == 'SAT').length;
    final weightedScore = _weightedScore(votes);

    final strongestVote = votes.reduce(
      (current, next) => current.score >= next.score ? current : next,
    );

    return CouncilResult(
      finalDecision: _finalDecision(
        buyVotes: buyVotes,
        waitVotes: waitVotes,
        sellVotes: sellVotes,
        weightedScore: weightedScore,
      ),
      confidence: _confidence(
        votes: votes,
        weightedScore: weightedScore,
        buyVotes: buyVotes,
        waitVotes: waitVotes,
        sellVotes: sellVotes,
      ),
      buyVotes: buyVotes,
      waitVotes: waitVotes,
      sellVotes: sellVotes,
      strongestEngine: strongestVote.engine,
      conflictSummary: _conflictSummary(votes),
      votes: List<CouncilVote>.unmodifiable(votes),
    );
  }

  static bool _isBuy(CouncilVote vote) {
    return vote.decision == 'AL' || vote.decision == 'GÜÇLÜ AL';
  }

  static int _weightedScore(List<CouncilVote> votes) {
    const weights = <String, double>{
      'Teknik AI': 0.20,
      'Smart Money AI': 0.24,
      'Haber AI': 0.10,
      'Risk AI': 0.16,
      'Momentum AI': 0.16,
      'Game Theory AI': 0.14,
    };

    double total = 0;
    for (final vote in votes) {
      total += vote.score * (weights[vote.engine] ?? 0);
    }
    return total.round().clamp(0, 100);
  }

  static String _finalDecision({
    required int buyVotes,
    required int waitVotes,
    required int sellVotes,
    required int weightedScore,
  }) {
    if (sellVotes >= 3 || weightedScore < 45) return 'SAT';
    if (buyVotes >= 5 && weightedScore >= 85) return 'GÜÇLÜ AL';
    if (buyVotes >= 4 && weightedScore >= 72) return 'AL';
    if (waitVotes >= 3 || weightedScore >= 52) return 'BEKLE';
    return 'RİSK AZALT';
  }

  static int _confidence({
    required List<CouncilVote> votes,
    required int weightedScore,
    required int buyVotes,
    required int waitVotes,
    required int sellVotes,
  }) {
    final scores = votes.map((vote) => vote.score).toList()..sort();
    final spread = scores.last - scores.first;

    final agreementBonus = buyVotes >= 5 || sellVotes >= 5
        ? 8
        : buyVotes >= 4 || sellVotes >= 4
            ? 5
            : waitVotes >= 4
                ? 3
                : 0;

    final conflictPenalty = spread > 35
        ? 8
        : spread > 25
            ? 4
            : 0;

    return (weightedScore + agreementBonus - conflictPenalty).clamp(0, 100);
  }

  static String _conflictSummary(List<CouncilVote> votes) {
    final buy = votes.where(_isBuy).map((vote) => vote.engine).toList();
    final wait = votes
        .where((vote) => vote.decision == 'BEKLE')
        .map((vote) => vote.engine)
        .toList();
    final sell = votes
        .where((vote) => vote.decision == 'SAT')
        .map((vote) => vote.engine)
        .toList();

    if (sell.isNotEmpty && buy.isNotEmpty) {
      return '${buy.join(', ')} alım tarafında; '
          '${sell.join(', ')} risk uyarısı veriyor.';
    }

    if (wait.isNotEmpty && buy.isNotEmpty) {
      return '${buy.join(', ')} alım yönünde; '
          '${wait.join(', ')} ek teyit bekliyor.';
    }

    if (buy.length == votes.length) {
      return 'Tüm AI motorları alım yönünde ortak görüş üretti.';
    }

    if (sell.length == votes.length) {
      return 'Tüm AI motorları risk azaltma yönünde ortak görüş üretti.';
    }

    return 'Konsey görüşleri dengeli; yeni veriyle karar güncellenmeli.';
  }
}
