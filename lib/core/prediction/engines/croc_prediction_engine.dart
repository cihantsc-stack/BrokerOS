import '../../models/stock_analysis.dart';
import '../models/croc_prediction.dart';
import '../models/prediction_horizon.dart';
import '../models/prediction_snapshot.dart';

class CrocPredictionEngine {
  const CrocPredictionEngine();

  List<CrocPrediction> analyze(StockAnalysis stock) {
    final snapshot = PredictionSnapshot.fromStock(stock);

    return PredictionHorizon.values
        .map(
          (horizon) => _analyze(
            stock,
            snapshot,
            horizon,
          ),
        )
        .toList(growable: false);
  }

  CrocPrediction _analyze(
    StockAnalysis stock,
    PredictionSnapshot snapshot,
    PredictionHorizon horizon,
  ) {
    final weights = _weights(horizon);

    double weightedSum = 0;
    double totalWeight = 0;

    void add(int value, double weight) {
      if (value <= 0) return;

      weightedSum += value.clamp(0, 100) * weight;
      totalWeight += weight;
    }

    add(stock.technicalScore, weights.technical);
    add(stock.smartMoneyScore, weights.smartMoney);
    add(stock.institutionalScore, weights.institutional);
    add(stock.momentumScore, weights.momentum);
    add(stock.newsScore, weights.news);

    if (stock.riskScore > 0) {
      add(
        100 - stock.riskScore.clamp(0, 100),
        weights.riskDiscipline,
      );
    }

    final rawScore =
        totalWeight <= 0 ? 0.0 : weightedSum / totalWeight;

    final coverage =
        (stock.activeSignalCount / 6.0).clamp(0.0, 1.0).toDouble();

    final agreement = _agreement(stock);

    final conflictPenalty = _conflictPenalty(stock);

    final regime = _regime(stock);

    final regimeAdjustment = _regimeAdjustment(
      stock: stock,
      horizon: horizon,
      regime: regime,
    );

    final coveragePenalty = _coveragePenalty(
      activeSignalCount: stock.activeSignalCount,
      horizon: horizon,
    );

    final adjustedScore = (
      rawScore +
      regimeAdjustment -
      conflictPenalty -
      coveragePenalty
    ).clamp(0.0, 100.0);

    final confidence = (
      (coverage * 52) +
      (agreement * 38) +
      (_confidenceBonus(stock) * 10)
    ).round().clamp(0, 100);

    final confidenceAdjusted = (
      confidence -
      _confidenceCoveragePenalty(stock.activeSignalCount)
    ).clamp(0, 100);

    final probability = (
      (adjustedScore * 0.82) +
      (confidenceAdjusted * 0.18)
    ).round().clamp(5, 95);

    final risk = stock.riskScore > 0
        ? stock.riskScore.clamp(0, 100).toInt()
        : _inferredRisk(stock);

    final direction = _direction(
      probability,
      confidenceAdjusted,
      risk,
    );

    final positiveFactors = _positive(
      stock,
      horizon,
      regime,
    );

    final negativeFactors = _negative(
      stock,
      horizon,
      conflictPenalty,
      coveragePenalty,
    );

    return CrocPrediction(
      symbol: stock.symbol.toUpperCase(),
      horizon: horizon,
      modelProbability: probability,
      confidence: confidenceAdjusted,
      riskScore: risk,
      direction: direction,
      regime: regime,
      shadowMode: true,
      positiveFactors: positiveFactors,
      negativeFactors: negativeFactors,
      snapshot: snapshot,
    );
  }

  _PredictionWeights _weights(
    PredictionHorizon horizon,
  ) {
    switch (horizon) {
      case PredictionHorizon.oneDay:
        return const _PredictionWeights(
          technical: 0.16,
          smartMoney: 0.24,
          institutional: 0.18,
          momentum: 0.26,
          news: 0.10,
          riskDiscipline: 0.06,
        );

      case PredictionHorizon.fiveDays:
        return const _PredictionWeights(
          technical: 0.24,
          smartMoney: 0.22,
          institutional: 0.20,
          momentum: 0.16,
          news: 0.08,
          riskDiscipline: 0.10,
        );

      case PredictionHorizon.twentyDays:
        return const _PredictionWeights(
          technical: 0.28,
          smartMoney: 0.15,
          institutional: 0.22,
          momentum: 0.08,
          news: 0.07,
          riskDiscipline: 0.20,
        );
    }
  }

  double _agreement(StockAnalysis stock) {
    final scores = <int>[
      stock.technicalScore,
      stock.smartMoneyScore,
      stock.institutionalScore,
      stock.momentumScore,
      stock.newsScore,
      if (stock.riskScore > 0)
        100 - stock.riskScore.clamp(0, 100).toInt(),
    ].where((value) => value > 0).toList();

    if (scores.isEmpty) return 0.0;
    if (scores.length == 1) return 0.45;

    final mean =
        scores.reduce((a, b) => a + b) / scores.length;

    final variance = scores
            .map(
              (value) =>
                  (value - mean) * (value - mean),
            )
            .reduce((a, b) => a + b) /
        scores.length;

    final standardDeviation = _sqrt(variance);

    return (1.0 - (standardDeviation / 42.0))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;

    var x = value;

    for (var i = 0; i < 14; i++) {
      x = 0.5 * (x + value / x);
    }

    return x;
  }

  double _conflictPenalty(
    StockAnalysis stock,
  ) {
    final scores = <int>[
      stock.technicalScore,
      stock.smartMoneyScore,
      stock.institutionalScore,
      stock.momentumScore,
      stock.newsScore,
    ].where((value) => value > 0).toList();

    if (scores.length < 2) return 0;

    final strongPositive =
        scores.where((value) => value >= 65).length;

    final strongNegative =
        scores.where((value) => value <= 40).length;

    if (strongPositive >= 2 && strongNegative >= 2) {
      return 8.0;
    }

    if (strongPositive >= 1 && strongNegative >= 2) {
      return 5.0;
    }

    if (strongPositive >= 2 && strongNegative >= 1) {
      return 3.0;
    }

    return 0.0;
  }

  double _coveragePenalty({
    required int activeSignalCount,
    required PredictionHorizon horizon,
  }) {
    if (activeSignalCount >= 5) return 0.0;

    switch (horizon) {
      case PredictionHorizon.oneDay:
        if (activeSignalCount == 4) return 2.0;
        if (activeSignalCount == 3) return 6.0;
        if (activeSignalCount == 2) return 11.0;
        return 18.0;

      case PredictionHorizon.fiveDays:
        if (activeSignalCount == 4) return 3.0;
        if (activeSignalCount == 3) return 7.0;
        if (activeSignalCount == 2) return 12.0;
        return 19.0;

      case PredictionHorizon.twentyDays:
        if (activeSignalCount == 4) return 4.0;
        if (activeSignalCount == 3) return 9.0;
        if (activeSignalCount == 2) return 15.0;
        return 22.0;
    }
  }

  int _confidenceCoveragePenalty(
    int activeSignalCount,
  ) {
    if (activeSignalCount >= 6) return 0;
    if (activeSignalCount == 5) return 3;
    if (activeSignalCount == 4) return 7;
    if (activeSignalCount == 3) return 12;
    if (activeSignalCount == 2) return 20;
    if (activeSignalCount == 1) return 30;
    return 40;
  }

  double _confidenceBonus(
    StockAnalysis stock,
  ) {
    var bonus = 0.0;

    if (stock.technicalScore >= 60 &&
        stock.momentumScore >= 60) {
      bonus += 0.35;
    }

    if (stock.smartMoneyScore >= 60 &&
        stock.institutionalScore >= 60) {
      bonus += 0.35;
    }

    if (stock.newsScore >= 55) {
      bonus += 0.15;
    }

    if (stock.riskScore > 0 &&
        stock.riskScore <= 45) {
      bonus += 0.15;
    }

    return bonus.clamp(0.0, 1.0);
  }

  double _regimeAdjustment({
    required StockAnalysis stock,
    required PredictionHorizon horizon,
    required String regime,
  }) {
    if (regime == 'TREND DESTEKLİ') {
      switch (horizon) {
        case PredictionHorizon.oneDay:
          return 2.0;
        case PredictionHorizon.fiveDays:
          return 4.0;
        case PredictionHorizon.twentyDays:
          return 5.0;
      }
    }

    if (regime == 'PARA AKIŞI DESTEKLİ') {
      switch (horizon) {
        case PredictionHorizon.oneDay:
          return 4.0;
        case PredictionHorizon.fiveDays:
          return 3.0;
        case PredictionHorizon.twentyDays:
          return 2.0;
      }
    }

    if (regime == 'TREND VAR / MOMENTUM ZAYIF') {
      switch (horizon) {
        case PredictionHorizon.oneDay:
          return -5.0;
        case PredictionHorizon.fiveDays:
          return -2.0;
        case PredictionHorizon.twentyDays:
          return 1.0;
      }
    }

    if (regime == 'VERİ KAPSAMI DÜŞÜK') {
      return -3.0;
    }

    return 0.0;
  }

  int _inferredRisk(
    StockAnalysis stock,
  ) {
    final negativeSignals = <int>[
      stock.technicalScore,
      stock.smartMoneyScore,
      stock.institutionalScore,
      stock.momentumScore,
      stock.newsScore,
    ].where(
      (value) => value > 0 && value < 50,
    ).length;

    if (negativeSignals >= 4) return 78;
    if (negativeSignals >= 3) return 68;
    if (negativeSignals >= 2) return 58;
    if (negativeSignals == 1) return 48;

    return 38;
  }

  String _direction(
    int probability,
    int confidence,
    int risk,
  ) {
    if (confidence < 35) {
      return 'VERİ YETERSİZ';
    }

    if (probability >= 78 &&
        confidence >= 62 &&
        risk <= 55) {
      return 'GÜÇLÜ POZİTİF';
    }

    if (probability >= 65 &&
        confidence >= 48 &&
        risk <= 65) {
      return 'POZİTİF';
    }

    if (probability >= 52) {
      return 'NÖTR / TEYİT';
    }

    if (probability >= 42) {
      return 'ZAYIF';
    }

    return 'NEGATİF';
  }

  String _regime(
    StockAnalysis stock,
  ) {
    if (stock.activeSignalCount <= 2) {
      return 'VERİ KAPSAMI DÜŞÜK';
    }

    if (stock.technicalScore >= 65 &&
        stock.momentumScore >= 60 &&
        stock.smartMoneyScore >= 60) {
      return 'TREND DESTEKLİ';
    }

    if (stock.technicalScore >= 60 &&
        stock.momentumScore > 0 &&
        stock.momentumScore < 50) {
      return 'TREND VAR / MOMENTUM ZAYIF';
    }

    if (stock.smartMoneyScore >= 65 &&
        stock.institutionalScore >= 60) {
      return 'PARA AKIŞI DESTEKLİ';
    }

    return 'KARIŞIK REJİM';
  }

  List<String> _positive(
    StockAnalysis stock,
    PredictionHorizon horizon,
    String regime,
  ) {
    final factors = <String>[];

    if (stock.technicalScore >= 60) {
      factors.add('Teknik yapı destekliyor');
    }

    if (stock.smartMoneyScore >= 60) {
      factors.add('Smart Money pozitif');
    }

    if (stock.institutionalScore >= 60) {
      factors.add('Kurumsal akış destekliyor');
    }

    if (stock.momentumScore >= 60) {
      factors.add('Momentum güçlü');
    }

    if (stock.newsScore >= 60) {
      factors.add('Haber/KAP etkisi olumlu');
    }

    if (stock.riskScore > 0 &&
        stock.riskScore <= 45) {
      factors.add('Risk baskısı sınırlı');
    }

    if (regime == 'TREND DESTEKLİ') {
      factors.add(
        '${horizon.label} görünümünde trend teyidi var',
      );
    }

    if (regime == 'PARA AKIŞI DESTEKLİ') {
      factors.add(
        '${horizon.label} görünümünde para akışı güçlü',
      );
    }

    return factors;
  }

  List<String> _negative(
    StockAnalysis stock,
    PredictionHorizon horizon,
    double conflictPenalty,
    double coveragePenalty,
  ) {
    final factors = <String>[];

    if (stock.technicalScore > 0 &&
        stock.technicalScore < 45) {
      factors.add('Teknik yapı zayıf');
    }

    if (stock.smartMoneyScore > 0 &&
        stock.smartMoneyScore < 45) {
      factors.add('Smart Money desteği zayıf');
    }

    if (stock.institutionalScore > 0 &&
        stock.institutionalScore < 45) {
      factors.add('Kurumsal akış zayıf');
    }

    if (stock.momentumScore > 0 &&
        stock.momentumScore < 45) {
      factors.add('Momentum zayıf');
    }

    if (stock.newsScore > 0 &&
        stock.newsScore < 45) {
      factors.add('Haber/KAP etkisi zayıf');
    }

    if (stock.riskScore >= 60) {
      factors.add('Risk skoru yüksek');
    }

    if (stock.activeSignalCount < 4) {
      factors.add(
        '${horizon.label} için veri kapsamı sınırlı',
      );
    }

    if (conflictPenalty >= 5) {
      factors.add('Ana sinyaller arasında belirgin çelişki var');
    }

    if (coveragePenalty >= 10) {
      factors.add('Eksik veri model skorunu aşağı çekiyor');
    }

    return factors;
  }
}

class _PredictionWeights {
  final double technical;
  final double smartMoney;
  final double institutional;
  final double momentum;
  final double news;
  final double riskDiscipline;

  const _PredictionWeights({
    required this.technical,
    required this.smartMoney,
    required this.institutional,
    required this.momentum,
    required this.news,
    required this.riskDiscipline,
  });
}
