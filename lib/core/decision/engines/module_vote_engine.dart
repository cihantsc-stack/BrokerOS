import '../../models/stock_analysis.dart';
import '../models/decision_vote.dart';

class ModuleVoteEngine {
  const ModuleVoteEngine();

  List<DecisionVote> evaluate(StockAnalysis stock) {
    final votes = <DecisionVote>[];

    void addStandard({
      required String module,
      required int score,
      required String positiveReason,
      required String negativeReason,
    }) {
      // 0 = veri yok / modül henüz aktif değil.
      if (score <= 0) return;

      votes.add(
        _buildVote(
          module: module,
          score: score,
          positiveReason: positiveReason,
          negativeReason: negativeReason,
        ),
      );
    }

    addStandard(
      module: 'Teknik Analiz',
      score: stock.technicalScore,
      positiveReason: 'Trend ve teknik yapı kararı destekliyor.',
      negativeReason: 'Teknik yapı henüz yeterli teyit üretmedi.',
    );

    addStandard(
      module: 'Smart Money',
      score: stock.smartMoneyScore,
      positiveReason: 'Akıllı para akışı pozitif bölgede.',
      negativeReason: 'Smart Money desteği zayıf.',
    );

    addStandard(
      module: 'Kurumsal Para',
      score: stock.institutionalScore,
      positiveReason: 'Kurumsal yatırımcı eğilimi olumlu.',
      negativeReason: 'Kurumsal alım desteği sınırlı.',
    );

    addStandard(
      module: 'Momentum',
      score: stock.momentumScore,
      positiveReason: 'Fiyat momentumu yukarı yönlü.',
      negativeReason: 'Momentum kaybı izleniyor.',
    );

    addStandard(
      module: 'Haber Etkisi',
      score: stock.newsScore,
      positiveReason: 'Haber akışı fiyatlamayı destekliyor.',
      negativeReason: 'Haber etkisi zayıf veya belirsiz.',
    );

    if (stock.riskScore > 0) {
      votes.add(_buildRiskVote(stock.riskScore));
    }

    return List<DecisionVote>.unmodifiable(votes);
  }

  DecisionVote _buildVote({
    required String module,
    required int score,
    required String positiveReason,
    required String negativeReason,
  }) {
    final normalized = score.clamp(0, 100);

    if (normalized >= 84) {
      return DecisionVote(
        module: module,
        vote: DecisionVoteType.strongBuy,
        score: normalized,
        reason: positiveReason,
      );
    }

    if (normalized >= 68) {
      return DecisionVote(
        module: module,
        vote: DecisionVoteType.buy,
        score: normalized,
        reason: positiveReason,
      );
    }

    if (normalized >= 54) {
      return DecisionVote(
        module: module,
        vote: DecisionVoteType.neutral,
        score: normalized,
        reason: 'Modül dengeli ve ek teyit bekliyor.',
      );
    }

    if (normalized >= 42) {
      return DecisionVote(
        module: module,
        vote: DecisionVoteType.wait,
        score: normalized,
        reason: negativeReason,
      );
    }

    return DecisionVote(
      module: module,
      vote: DecisionVoteType.sell,
      score: normalized,
      reason: negativeReason,
    );
  }

  DecisionVote _buildRiskVote(int riskScore) {
    // riskScore semantiği:
    // 0   = veri yok
    // 100 = çok yüksek risk
    final risk = riskScore.clamp(0, 100);

    // Karar motorlarında skor yüksek = olumlu olduğu için,
    // risk kalitesini ters çeviriyoruz.
    final quality = 100 - risk;

    if (risk <= 25) {
      return DecisionVote(
        module: 'Risk Disiplini',
        vote: DecisionVoteType.buy,
        score: quality,
        reason: 'Risk seviyesi düşük; işlem planı kontrollü.',
      );
    }

    if (risk <= 50) {
      return DecisionVote(
        module: 'Risk Disiplini',
        vote: DecisionVoteType.neutral,
        score: quality,
        reason: 'Risk orta seviyede; stop disiplini gerekli.',
      );
    }

    if (risk <= 70) {
      return DecisionVote(
        module: 'Risk Disiplini',
        vote: DecisionVoteType.wait,
        score: quality,
        reason: 'Risk seviyesi yükselmiş; yeni işlem için temkin gerekli.',
      );
    }

    return DecisionVote(
      module: 'Risk Disiplini',
      vote: DecisionVoteType.sell,
      score: quality,
      reason: 'Risk seviyesi yüksek; yeni pozisyon için uygun değil.',
    );
  }
}
