import '../analysis/croc_technical_analysis.dart';
import '../kap_intelligence/kap_intelligence_service.dart';
import '../master_engine/croc_master_stock_engine.dart';

enum CrocHorizon { intraday, week, month, threeMonths, sixMonths }

class CrocHorizonResult {
  final CrocHorizon horizon;
  final String label;
  final String decision;
  final int score;
  final int confidence;
  final double? entryLow;
  final double? entryHigh;
  final double? stop;
  final double? target1;
  final double? target2;
  final double? target3;
  final List<String> reasons;
  final List<String> missingLayers;

  const CrocHorizonResult({
    required this.horizon,
    required this.label,
    required this.decision,
    required this.score,
    required this.confidence,
    required this.entryLow,
    required this.entryHigh,
    required this.stop,
    required this.target1,
    required this.target2,
    required this.target3,
    required this.reasons,
    required this.missingLayers,
  });

  bool get available => score > 0;
}

class CrocHorizonEngine {
  const CrocHorizonEngine();

  List<CrocHorizonResult> evaluate({
    required double price,
    required CrocTechnicalAnalysis? technical,
    required CrocMasterStockResult? master,
    required KapIntelligenceResult kap,
  }) {
    return CrocHorizon.values
        .map(
          (horizon) => _evaluateOne(
            horizon: horizon,
            price: price,
            technical: technical,
            master: master,
            kap: kap,
          ),
        )
        .toList(growable: false);
  }

  CrocHorizonResult _evaluateOne({
    required CrocHorizon horizon,
    required double price,
    required CrocTechnicalAnalysis? technical,
    required CrocMasterStockResult? master,
    required KapIntelligenceResult kap,
  }) {
    final label = _label(horizon);
    if (technical == null || price <= 0) {
      return CrocHorizonResult(
        horizon: horizon,
        label: label,
        decision: 'VERİ BEKLENİYOR',
        score: 0,
        confidence: 0,
        entryLow: null,
        entryHigh: null,
        stop: null,
        target1: null,
        target2: null,
        target3: null,
        reasons: const ['Gerçek teknik veri tamamlanmadan yorum üretilmez.'],
        missingLayers: const ['teknik veri'],
      );
    }

    final technicalScore = technical.score.clamp(0, 100).toDouble();
    final masterScore = (master?.masterScore ?? technical.score)
        .clamp(0, 100)
        .toDouble();
    final momentumScore = _momentumScore(technical);
    final trendScore = _trendScore(price, technical);
    final volumeScore = _volumeScore(technical.volumeRatio);
    final kapScore = kap.hasData ? kap.score.clamp(0, 100).toDouble() : 0.0;

    late double score;
    final missing = <String>[];

    switch (horizon) {
      case CrocHorizon.intraday:
        score =
            momentumScore * .34 +
            trendScore * .26 +
            volumeScore * .25 +
            technicalScore * .15;
        break;
      case CrocHorizon.week:
        score =
            technicalScore * .30 +
            momentumScore * .24 +
            trendScore * .21 +
            volumeScore * .15 +
            masterScore * .10;
        break;
      case CrocHorizon.month:
        score =
            masterScore * .35 +
            technicalScore * .25 +
            trendScore * .15 +
            momentumScore * .10 +
            kapScore * .15;
        if (!kap.hasData) missing.add('KAP');
        missing.add('fon hareketi');
        break;
      case CrocHorizon.threeMonths:
        score =
            masterScore * .30 +
            technicalScore * .20 +
            trendScore * .10 +
            kapScore * .20 +
            momentumScore * .05 +
            volumeScore * .05;
        if (!kap.hasData) missing.add('KAP');
        missing
          ..add('fon hareketi')
          ..add('temel/sektör');
        break;
      case CrocHorizon.sixMonths:
        score =
            masterScore * .25 +
            technicalScore * .15 +
            trendScore * .10 +
            kapScore * .20 +
            momentumScore * .05 +
            volumeScore * .05;
        if (!kap.hasData) missing.add('KAP');
        missing
          ..add('fon hareketi')
          ..add('temel/sektör')
          ..add('makro rejim');
        break;
    }

    var confidence = master?.masterConfidence ?? 55;
    confidence = confidence.clamp(0, 100);

    if (technical.volumeRatio < .9) {
      confidence -= horizon == CrocHorizon.intraday ? 14 : 6;
    }
    if (missing.isNotEmpty) confidence -= missing.length * 9;
    if (horizon == CrocHorizon.month) confidence = confidence.clamp(0, 78);
    if (horizon == CrocHorizon.threeMonths) {
      confidence = confidence.clamp(0, 68);
    }
    if (horizon == CrocHorizon.sixMonths) {
      confidence = confidence.clamp(0, 58);
    }
    confidence = confidence.clamp(20, 100);

    final roundedScore = score.round().clamp(0, 100);
    final decision = _decision(
      score: roundedScore,
      confidence: confidence,
      horizon: horizon,
      missing: missing,
      volumeRatio: technical.volumeRatio,
    );
    final levels = _levels(price, technical, horizon);

    return CrocHorizonResult(
      horizon: horizon,
      label: label,
      decision: decision,
      score: roundedScore,
      confidence: confidence,
      entryLow: levels.entryLow,
      entryHigh: levels.entryHigh,
      stop: levels.stop,
      target1: levels.target1,
      target2: levels.target2,
      target3: levels.target3,
      reasons: _reasons(
        price: price,
        technical: technical,
        kap: kap,
        horizon: horizon,
      ),
      missingLayers: missing,
    );
  }

  double _momentumScore(CrocTechnicalAnalysis a) {
    var score = 50.0;
    if (a.rsi >= 52 && a.rsi <= 68) score += 20;
    if (a.rsi > 70) score -= 12;
    if (a.rsi < 35) score -= 10;
    if (a.macd > a.macdSignal) score += 18;
    if (a.macd < a.macdSignal) score -= 12;
    return score.clamp(0, 100);
  }

  double _trendScore(double price, CrocTechnicalAnalysis a) {
    var score = 50.0;
    if (a.ema20 > 0 && price > a.ema20) score += 20;
    if (a.ema20 > 0 && price < a.ema20) score -= 15;
    final trend = a.trend.toUpperCase();
    if (trend.contains('YÜK') || trend.contains('YUK')) score += 20;
    if (trend.contains('DÜŞ') || trend.contains('DUS')) score -= 20;
    return score.clamp(0, 100);
  }

  double _volumeScore(double ratio) {
    if (ratio <= 0) return 25;
    if (ratio >= 1.5) return 92;
    if (ratio >= 1.2) return 80;
    if (ratio >= 1.0) return 68;
    if (ratio >= .9) return 58;
    if (ratio >= .7) return 42;
    return 28;
  }

  String _decision({
    required int score,
    required int confidence,
    required CrocHorizon horizon,
    required List<String> missing,
    required double volumeRatio,
  }) {
    if (confidence < 38) return 'BEKLE';

    if (horizon == CrocHorizon.intraday) {
      if (volumeRatio < .75) {
        return score >= 68 ? 'TEYİT BEKLE' : 'BEKLE';
      }
      if (volumeRatio < 1.0 && score >= 72) return 'KADEMELİ AL';
    }

    if ((horizon == CrocHorizon.threeMonths ||
            horizon == CrocHorizon.sixMonths) &&
        missing.length >= 2) {
      return score >= 58 ? 'İZLE' : 'BEKLE';
    }

    if (horizon == CrocHorizon.month && missing.length >= 2 && score >= 68) {
      return 'İZLE';
    }

    if (score >= 74 && confidence >= 55) return 'AL';
    if (score >= 60) return 'İZLE';
    if (score >= 45) return 'BEKLE';
    return 'UZAK DUR';
  }

  _CrocLevels _levels(
    double price,
    CrocTechnicalAnalysis a,
    CrocHorizon horizon,
  ) {
    final atr = a.atr > 0 ? a.atr : 0.0;
    if (atr <= 0) {
      return _CrocLevels(
        entryLow: a.support > 0 ? a.support : null,
        entryHigh: price,
        stop: a.stop > 0 ? a.stop : null,
        target1: a.target > price ? a.target : null,
        target2: null,
        target3: null,
      );
    }

    late double entryLow;
    late double entryHigh;
    late double stop;
    late double target1;
    late double target2;
    late double target3;

    switch (horizon) {
      case CrocHorizon.intraday:
        entryLow = price - atr * .45;
        entryHigh = price + atr * .12;
        stop = price - atr * .80;
        target1 = price + atr * .55;
        target2 = price + atr * 1.05;
        target3 = price + atr * 1.55;
        break;
      case CrocHorizon.week:
        entryLow = price - atr * .85;
        entryHigh = price + atr * .18;
        stop = price - atr * 1.25;
        target1 = price + atr * 1.15;
        target2 = price + atr * 1.85;
        target3 = price + atr * 2.55;
        break;
      case CrocHorizon.month:
        entryLow = price - atr * 1.25;
        entryHigh = price + atr * .20;
        stop = price - atr * 1.75;
        target1 = price + atr * 1.65;
        target2 = price + atr * 2.70;
        target3 = price + atr * 3.80;
        break;
      case CrocHorizon.threeMonths:
        entryLow = price - atr * 1.65;
        entryHigh = price + atr * .25;
        stop = price - atr * 2.20;
        target1 = price + atr * 2.20;
        target2 = price + atr * 3.70;
        target3 = price + atr * 5.20;
        break;
      case CrocHorizon.sixMonths:
        entryLow = price - atr * 2.10;
        entryHigh = price + atr * .30;
        stop = price - atr * 2.80;
        target1 = price + atr * 2.80;
        target2 = price + atr * 4.80;
        target3 = price + atr * 6.80;
        break;
    }

    if (a.support > 0 && a.support < price) {
      final maxSupportDistance = switch (horizon) {
        CrocHorizon.intraday => atr * .70,
        CrocHorizon.week => atr * 1.10,
        CrocHorizon.month => atr * 1.55,
        CrocHorizon.threeMonths => atr * 2.10,
        CrocHorizon.sixMonths => atr * 2.60,
      };
      if ((price - a.support) <= maxSupportDistance) {
        entryLow = a.support;
      }
    }

    return _CrocLevels(
      entryLow: entryLow > 0 ? entryLow : null,
      entryHigh: entryHigh > 0 ? entryHigh : null,
      stop: stop > 0 ? stop : null,
      target1: target1 > price ? target1 : null,
      target2: target2 > price ? target2 : null,
      target3: target3 > price ? target3 : null,
    );
  }

  List<String> _reasons({
    required double price,
    required CrocTechnicalAnalysis technical,
    required KapIntelligenceResult kap,
    required CrocHorizon horizon,
  }) {
    final reasons = <String>[];

    if (technical.ema20 > 0) {
      reasons.add(
        price >= technical.ema20
            ? 'Fiyat EMA20 üzerinde.'
            : 'Fiyat EMA20 altında.',
      );
    }

    reasons.add(
      technical.macd >= technical.macdSignal
          ? 'MACD momentumu destekliyor.'
          : 'MACD momentumu zayıf.',
    );

    if (horizon == CrocHorizon.intraday || horizon == CrocHorizon.week) {
      reasons.add(
        technical.volumeRatio >= 1
            ? 'Hacim teyidi güçlü.'
            : 'Hacim teyidi zayıf; fiyat kovalanmamalı.',
      );
    } else if (kap.hasData) {
      reasons.add(
        kap.score >= 55 ? 'KAP etkisi destekliyor.' : 'KAP etkisi temkinli.',
      );
    } else {
      reasons.add('KAP verisi yok; uzun vade güveni düşürüldü.');
    }

    return reasons.take(3).toList(growable: false);
  }

  String _label(CrocHorizon horizon) => switch (horizon) {
    CrocHorizon.intraday => 'Gün İçi',
    CrocHorizon.week => '1 Hafta',
    CrocHorizon.month => '1 Ay',
    CrocHorizon.threeMonths => '3 Ay',
    CrocHorizon.sixMonths => '6 Ay',
  };
}

class _CrocLevels {
  final double? entryLow;
  final double? entryHigh;
  final double? stop;
  final double? target1;
  final double? target2;
  final double? target3;

  const _CrocLevels({
    required this.entryLow,
    required this.entryHigh,
    required this.stop,
    required this.target1,
    required this.target2,
    required this.target3,
  });
}
