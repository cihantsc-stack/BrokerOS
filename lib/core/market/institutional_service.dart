class InstitutionalFlowResult {
  final double score;
  final double netBuyMillion;
  final List<String> topBuyers;
  final List<String> topSellers;
  final String summary;

  const InstitutionalFlowResult({
    required this.score,
    required this.netBuyMillion,
    required this.topBuyers,
    required this.topSellers,
    required this.summary,
  });
}

class InstitutionalService {
  const InstitutionalService();

  InstitutionalFlowResult analyze({
    required double netBuyMillion,
    required List<String> topBuyers,
    required List<String> topSellers,
    required double buySellRatio,
  }) {
    double score = 50;

    score += (buySellRatio - 1) * 25;

    if (netBuyMillion > 0) {
      score += netBuyMillion / 10;
    } else {
      score += netBuyMillion / 15;
    }

    score = score.clamp(0, 100);

    String summary;

    if (score >= 75) {
      summary = "Kurumsal yatırımcılar güçlü şekilde alım tarafında.";
    } else if (score >= 60) {
      summary = "Kurumsal tarafta hafif pozitif görünüm mevcut.";
    } else if (score >= 40) {
      summary = "Kurumsal işlemler dengeli seyrediyor.";
    } else {
      summary = "Kurumsal yatırımcılar satış tarafında baskın.";
    }

    return InstitutionalFlowResult(
      score: score,
      netBuyMillion: netBuyMillion,
      topBuyers: topBuyers,
      topSellers: topSellers,
      summary: summary,
    );
  }

  bool isBullish(InstitutionalFlowResult result) => result.score >= 70;

  bool isBearish(InstitutionalFlowResult result) => result.score <= 35;
}
