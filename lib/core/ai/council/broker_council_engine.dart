import '../../models/stock_analysis.dart';
import 'council_result.dart';
import 'council_vote.dart';
import 'game_theory_ai.dart';
import 'momentum_ai.dart';
import 'news_ai.dart';
import 'smart_money_ai.dart';
import 'technical_ai.dart';

class BrokerCouncilEngine {
  const BrokerCouncilEngine._();

  static CouncilResult evaluate(StockAnalysis stock) {
    final votes = <CouncilVote>[];

    // 0 = veri yok. Veri yoksa Council oylamasina GIRMEZ.
    if (stock.technicalScore > 0) {
      votes.add(TechnicalAi.evaluate(stock));
    }

    if (stock.smartMoneyScore > 0) {
      votes.add(SmartMoneyAi.evaluate(stock));
    }

    if (stock.newsScore > 0) {
      votes.add(NewsAi.evaluate(stock));
    }

    if (stock.riskScore > 0) {
      votes.add(_riskVote(stock.riskScore));
    }

    if (stock.momentumScore > 0) {
      votes.add(MomentumAi.evaluate(stock));
    }

    // Game Theory ancak gerekli uc veri de gercekten varsa calisir.
    if (stock.smartMoneyScore > 0 &&
        stock.institutionalScore > 0 &&
        stock.momentumScore > 0) {
      votes.add(GameTheoryAi.evaluate(stock));
    }

    if (votes.isEmpty) {
      return const CouncilResult(
        finalDecision: 'VER\u0130 BEKLEN\u0130YOR',
        confidence: 0,
        buyVotes: 0,
        waitVotes: 0,
        sellVotes: 0,
        strongestEngine: 'Veri bekleniyor',
        conflictSummary: 'Council icin aktif veri kaynagi bulunmuyor.',
        votes: <CouncilVote>[],
      );
    }

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
        totalVotes: votes.length,
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

  static CouncilVote _riskVote(int rawRiskScore) {
    // StockAnalysis semantigi:
    // 0 = veri yok
    // 100 = cok yuksek risk
    final risk = rawRiskScore.clamp(0, 100);

    // Council'de yuksek skor olumlu oldugu icin ters ceviriyoruz.
    final quality = 100 - risk;

    if (risk <= 25) {
      return CouncilVote(
        engine: 'Risk AI',
        decision: 'AL',
        score: quality,
        reason: 'Risk seviyesi dusuk; islem plani kontrollu.',
      );
    }

    if (risk <= 50) {
      return CouncilVote(
        engine: 'Risk AI',
        decision: 'BEKLE',
        score: quality,
        reason: 'Risk orta seviyede; stop disiplini gerekli.',
      );
    }

    return CouncilVote(
      engine: 'Risk AI',
      decision: 'SAT',
      score: quality,
      reason: 'Risk seviyesi yuksek; yeni pozisyon icin temkin gerekli.',
    );
  }

  static bool _isBuy(CouncilVote vote) {
    return vote.decision == 'AL' || vote.decision.endsWith('AL');
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

    double weighted = 0;
    double activeWeight = 0;

    for (final vote in votes) {
      final weight = weights[vote.engine] ?? 0;

      if (weight <= 0) {
        continue;
      }

      weighted += vote.score.clamp(0, 100) * weight;
      activeWeight += weight;
    }

    if (activeWeight <= 0) {
      return 0;
    }

    return (weighted / activeWeight).round().clamp(0, 100);
  }

  static String _finalDecision({
    required int buyVotes,
    required int waitVotes,
    required int sellVotes,
    required int weightedScore,
    required int totalVotes,
  }) {
    if (totalVotes == 0) {
      return 'VER\u0130 BEKLEN\u0130YOR';
    }

    final buyRatio = buyVotes / totalVotes;
    final sellRatio = sellVotes / totalVotes;

    if (sellRatio >= 0.60 || weightedScore < 42) {
      return 'SAT';
    }

    if (weightedScore >= 85 && buyRatio >= 0.75) {
      return 'G\u00dc\u00c7L\u00dc AL';
    }

    if (weightedScore >= 70 && buyRatio >= 0.50) {
      return 'AL';
    }

    if (weightedScore >= 52 || waitVotes > 0) {
      return 'BEKLE';
    }

    return 'R\u0130SK AZALT';
  }

  static int _confidence({
    required List<CouncilVote> votes,
    required int weightedScore,
    required int buyVotes,
    required int waitVotes,
    required int sellVotes,
  }) {
    if (votes.isEmpty) {
      return 0;
    }

    final scores = votes.map((vote) => vote.score).toList()..sort();
    final spread = scores.last - scores.first;

    final totalVotes = votes.length;
    final dominantVotes = <int>[buyVotes, waitVotes, sellVotes]..sort();

    final agreementRatio = dominantVotes.last / totalVotes;

    final agreementBonus = agreementRatio >= 0.80
        ? 8
        : agreementRatio >= 0.65
        ? 5
        : agreementRatio >= 0.50
        ? 2
        : 0;

    final conflictPenalty = spread > 45
        ? 8
        : spread > 30
        ? 4
        : 0;

    // Veri kapsami azsa guvenin gereksiz yere ucmasini engelle.
    final coverage = (totalVotes / 6.0).clamp(0.35, 1.0);

    final raw = weightedScore + agreementBonus - conflictPenalty;

    return (raw * (0.80 + coverage * 0.20)).round().clamp(0, 100);
  }

  static String _conflictSummary(List<CouncilVote> votes) {
    if (votes.isEmpty) {
      return 'Council veri bekliyor.';
    }

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
      return '${buy.join(', ')} alim tarafinda; '
          '${sell.join(', ')} risk uyarisi veriyor.';
    }

    if (wait.isNotEmpty && buy.isNotEmpty) {
      return '${buy.join(', ')} alim yonunde; '
          '${wait.join(', ')} ek teyit bekliyor.';
    }

    if (buy.length == votes.length) {
      return 'Tum aktif Council motorlari alim yonunde.';
    }

    if (sell.length == votes.length) {
      return 'Tum aktif Council motorlari risk azaltma yonunde.';
    }

    return 'Council gorusleri dengeli; yeni veriyle tekrar degerlendirilmeli.';
  }
}
