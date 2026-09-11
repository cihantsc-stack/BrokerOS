import '../../models/stock_analysis.dart';
import '../models/croc_decision_result.dart';
import '../models/decision_vote.dart';
import 'module_vote_engine.dart';

class CrocDecisionEngine {
  const CrocDecisionEngine();

  CrocDecisionResult analyze(StockAnalysis stock) {
    final votes = const ModuleVoteEngine().evaluate(stock);

    final weightedScore = _weightedScore(stock);

    final positiveVotes = votes
        .where((DecisionVote item) => item.isPositive)
        .length;

    final decision = _decisionFor(
      score: weightedScore,
      positiveVotes: positiveVotes,
      totalVotes: votes.length,
    );

    final entry = stock.entry > 0 ? stock.entry : (stock.lastPrice ?? 0);

    final target = stock.target1 > entry ? stock.target1 : entry * 1.08;

    final stop = stock.stop > 0 && stock.stop < entry
        ? stock.stop
        : entry * 0.96;

    final riskAmount = (entry - stop).abs();

    final riskReward = riskAmount == 0
        ? 0.0
        : (target - entry).abs() / riskAmount;

    final confidence = _confidence(weightedScore, positiveVotes, votes.length);

    final successProbability = ((weightedScore * 0.72) + (confidence * 0.28))
        .round()
        .clamp(0, 95);

    final reasons = votes
        .where((DecisionVote item) => item.isPositive)
        .map((DecisionVote item) => item.reason)
        .take(4)
        .toList();

    if (reasons.isEmpty) {
      reasons.add('Karar için ek teyit bekleniyor.');
    }

    final warnings = votes
        .where(
          (DecisionVote item) =>
              item.vote == DecisionVoteType.wait ||
              item.vote == DecisionVoteType.sell,
        )
        .map((DecisionVote item) => item.reason)
        .take(3)
        .toList();

    final narrative = _narrative(
      stock: stock,
      decision: decision,
      positiveVotes: positiveVotes,
      totalVotes: votes.length,
      riskReward: riskReward,
    );

    final invalidation = entry > 0
        ? '${stop.toStringAsFixed(2)} altında kapanışta olumlu senaryo bozulur.'
        : 'Stop seviyesi oluşmadan işlem kararı kesinleştirilmemeli.';

    return CrocDecisionResult(
      symbol: stock.symbol,
      decision: decision,
      score: weightedScore,
      confidence: confidence,
      successProbability: successProbability,
      risk: stock.risk,
      tradeWindow: _tradeWindow(weightedScore, stock.risk),
      entry: entry,
      target: target,
      stop: stop,
      riskReward: riskReward,
      votes: votes,
      reasons: reasons,
      warnings: warnings,
      narrative: narrative,
      invalidation: invalidation,
    );
  }

  int _weightedScore(StockAnalysis stock) {
    double weighted = 0;
    double totalWeight = 0;

    void add(int value, double weight) {
      if (value <= 0) return;

      weighted += value.clamp(0, 100) * weight;
      totalWeight += weight;
    }

    add(stock.technicalScore, 0.22);
    add(stock.smartMoneyScore, 0.21);
    add(stock.institutionalScore, 0.19);
    add(stock.momentumScore, 0.16);
    add(stock.newsScore, 0.10);

    // riskScore yüksek = kötü.
    if (stock.riskScore > 0) {
      add(100 - stock.riskScore.clamp(0, 100), 0.12);
    }

    if (totalWeight <= 0) return 0;

    return (weighted / totalWeight).round().clamp(0, 100);
  }

  int _confidence(int score, int positiveVotes, int totalVotes) {
    if (totalVotes <= 0) return 0;

    final voteRatio = positiveVotes / totalVotes;

    // Veri kapsamı düşükse güvenin uçmasını engelle.
    final coverage = (totalVotes / 6.0).clamp(0.35, 1.0);

    final raw = (score * 0.70) + (voteRatio * 100 * 0.30);

    return (raw * (0.75 + coverage * 0.25)).round().clamp(0, 100);
  }

  String _decisionFor({
    required int score,
    required int positiveVotes,
    required int totalVotes,
  }) {
    if (totalVotes == 0) {
      return 'VERİ BEKLENİYOR';
    }

    final requiredStrongVotes = totalVotes >= 5
        ? 5
        : (totalVotes * 0.75).ceil();

    final requiredBuyVotes = totalVotes >= 4 ? 4 : (totalVotes * 0.60).ceil();

    if (score >= 84 && positiveVotes >= requiredStrongVotes) {
      return 'GÜÇLÜ AL';
    }

    if (score >= 72 && positiveVotes >= requiredBuyVotes) {
      return 'SEÇİCİ AL';
    }

    if (score >= 60 && positiveVotes >= 1) {
      return 'İZLE / KADEMELİ';
    }

    if (score >= 48) {
      return 'TEYİT BEKLE';
    }

    return 'UZAK DUR';
  }

  String _tradeWindow(int score, String risk) {
    final normalizedRisk = risk.toUpperCase();

    if (score >= 84 && !normalizedRisk.contains('YÜKSEK')) {
      return '1-3 Gün';
    }

    if (score >= 70) {
      return '3-7 Gün';
    }

    if (score >= 58) {
      return '1-3 Hafta';
    }

    return 'İzleme';
  }

  String _narrative({
    required StockAnalysis stock,
    required String decision,
    required int positiveVotes,
    required int totalVotes,
    required double riskReward,
  }) {
    final missing = 6 - totalVotes;

    final coverageText = missing > 0
        ? '$totalVotes aktif modül kullanıldı, $missing modül veri bekliyor.'
        : 'Tüm modüller aktif.';

    return 'CROC AI, $totalVotes aktif modülün $positiveVotes tanesinden '
        'olumlu oy aldı. $coverageText '
        '${stock.symbol} için birleşik karar $decision seviyesinde. '
        'Risk/ödül oranı 1:${riskReward.toStringAsFixed(2)}.';
  }
}
