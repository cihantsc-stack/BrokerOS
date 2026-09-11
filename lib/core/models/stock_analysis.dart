class StockAnalysis {
  final String symbol;
  final String company;

  final int aiScore;
  final String decision;

  final double entry;
  final double target1;
  final double target2;
  final double stop;

  final int confidence;
  final String risk;
  final List<String> reasons;

  final double? lastPrice;
  final double? dailyChange;
  final double? volume;

  final String? firstInstitution;
  final String? secondInstitution;
  final String? thirdInstitution;
  final double? smartMoneyFlow;

  // 0 = veri kaynagi yok / henuz hesaplanmadi.
  final int technicalScore;
  final int smartMoneyScore;
  final int institutionalScore;
  final int newsScore;

  // riskScore: 0 veri yok, yuksek deger = yuksek risk.
  final int riskScore;

  final int momentumScore;

  const StockAnalysis({
    required this.symbol,
    required this.company,
    required this.aiScore,
    required this.decision,
    required this.entry,
    required this.target1,
    required this.target2,
    required this.stop,
    required this.confidence,
    required this.risk,
    required this.reasons,
    this.lastPrice,
    this.dailyChange,
    this.volume,
    this.firstInstitution,
    this.secondInstitution,
    this.thirdInstitution,
    this.smartMoneyFlow,
    this.technicalScore = 0,
    this.smartMoneyScore = 0,
    this.institutionalScore = 0,
    this.newsScore = 0,
    this.riskScore = 0,
    this.momentumScore = 0,
  });

  int get activeSignalCount {
    var count = 0;

    if (technicalScore > 0) count++;
    if (smartMoneyScore > 0) count++;
    if (institutionalScore > 0) count++;
    if (newsScore > 0) count++;
    if (riskScore > 0) count++;
    if (momentumScore > 0) count++;

    return count;
  }

  int get brokerConsensus {
    var weighted = 0.0;
    var totalWeight = 0.0;

    void add(int value, double weight) {
      if (value <= 0) return;

      weighted += value.clamp(0, 100) * weight;
      totalWeight += weight;
    }

    add(technicalScore, 0.22);
    add(smartMoneyScore, 0.25);
    add(institutionalScore, 0.18);
    add(momentumScore, 0.15);
    add(newsScore, 0.10);

    // Yuksek risk olumlu puan degildir.
    if (riskScore > 0) {
      add(100 - riskScore.clamp(0, 100), 0.10);
    }

    if (totalWeight <= 0) {
      return 0;
    }

    return (weighted / totalWeight).round().clamp(0, 100);
  }
}
