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
  final double? riskReward;
  final String levelQuality;
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
    required this.riskReward,
    required this.levelQuality,
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
        riskReward: null,
        levelQuality: 'VERİ BEKLENİYOR',
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
    final riskReward = _riskReward(
      price: price,
      stop: levels.stop,
      target: levels.target1,
    );
    final levelQuality = _levelQuality(
      riskReward: riskReward,
      stop: levels.stop,
      target: levels.target1,
      price: price,
    );

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
      riskReward: riskReward,
      levelQuality: levelQuality,
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
    // ============================================================
    // CROC SINGLE SOURCE OF TRUTH
    // ============================================================
    //
    // Horizon Engine artik kendi ATR tabanli stop/hedef seviyelerini
    // URETMEZ.
    //
    // Fiyat seviyelerinin tek kaynagi:
    // CrocTechnicalAnalysisEngine
    //
    // Horizon Engine sadece vade bazli:
    // - skor
    // - karar
    // - guven
    // - yorum
    // uretir.
    //
    // Boylece ana CROC ile Hizli Gorus birbirine ters fiyat
    // seviyeleri gostermez.
    // ============================================================

    final double entryLow = a.support > 0 && a.support < price
        ? a.support
        : price;

    final double? entryHigh = price > 0 ? price : null;

    final double? stop = a.stop > 0 && a.stop < price ? a.stop : null;

    final double? target1 = a.target > price ? a.target : null;

    final double? target2 = a.target2 > price ? a.target2 : null;

    final double? target3 = a.target3 > price ? a.target3 : null;

    return _CrocLevels(
      entryLow: entryLow,
      entryHigh: entryHigh,
      stop: stop,
      target1: target1,
      target2: target2,
      target3: target3,
    );
  }


  double? _riskReward({
    required double price,
    required double? stop,
    required double? target,
  }) {
    if (price <= 0 || stop == null || target == null) return null;

    final risk = price - stop;
    final reward = target - price;

    if (risk <= 0 || reward <= 0) return null;
    return reward / risk;
  }

  String _levelQuality({
    required double? riskReward,
    required double? stop,
    required double? target,
    required double price,
  }) {
    if (price <= 0 || stop == null || target == null || riskReward == null) {
      return 'EKSİK SEVİYE';
    }
    if (riskReward >= 2.0) return 'GÜÇLÜ';
    if (riskReward >= 1.3) return 'UYGUN';
    if (riskReward >= 1.0) return 'SINIRDA';
    return 'ZAYIF';
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
