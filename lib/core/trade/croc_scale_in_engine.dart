import 'dart:math' as math;

import '../analysis/croc_technical_analysis.dart';

class CrocScaleInStep {
  const CrocScaleInStep({
    required this.index,
    required this.low,
    required this.high,
    required this.allocationPercent,
  });

  final int index;
  final double low;
  final double high;
  final int allocationPercent;

  String get label => '$index. KADEME';
  bool contains(double price) => price >= low && price <= high;
}

class CrocScaleInPlan {
  const CrocScaleInPlan({
    required this.steps,
    required this.stop,
    required this.target,
    required this.status,
  });

  final List<CrocScaleInStep> steps;
  final double stop;
  final double target;
  final String status;

  CrocScaleInStep? get first => steps.isEmpty ? null : steps.first;
}

class CrocScaleInEngine {
  const CrocScaleInEngine();

  static CrocScaleInPlan build({
    required double currentPrice,
    required CrocTechnicalAnalysis analysis,
  }) {
    if (currentPrice <= 0 || analysis.atr <= 0 || analysis.stop <= 0) {
      return CrocScaleInPlan(
        steps: const [],
        stop: analysis.stop,
        target: analysis.target,
        status: 'VERİ BEKLENİYOR',
      );
    }

    final atr = analysis.atr;
    final stop = analysis.stop;
    final buffer = math.max(atr * .10, currentPrice * .001).toDouble();
    final minAllowed = stop + buffer;

    double safe(double value) => math.max(minAllowed, value).toDouble();

    final first = math
        .min(currentPrice * 1.005, analysis.support + atr * .55)
        .toDouble();

    final second = analysis.support2 > minAllowed
        ? analysis.support2 + atr * .12
        : analysis.support + atr * .20;

    final third = analysis.support3 > minAllowed
        ? analysis.support3 + atr * .10
        : math.max(minAllowed, analysis.support - atr * .10).toDouble();

    final anchors = <double>[safe(first), safe(second), safe(third)]
      ..sort((a, b) => b.compareTo(a));

    final unique = <double>[];
    final mergeDistance = math.max(atr * .18, currentPrice * .0025).toDouble();

    for (final anchor in anchors) {
      if (anchor <= stop) continue;
      if (unique.every((x) => (x - anchor).abs() > mergeDistance)) {
        unique.add(anchor);
      }
    }

    if (unique.isEmpty) {
      return CrocScaleInPlan(
        steps: const [],
        stop: stop,
        target: analysis.target,
        status: 'STOP ÜSTÜNDE GÜVENLİ KADEME YOK',
      );
    }

    final riskText = analysis.risk.toUpperCase();
    final riskFactor = riskText.contains('YÜKSEK')
        ? 1.0
        : riskText.contains('ORTA')
        ? .5
        : 0.0;

    final rawWeights = <double>[
      1.35 - (.55 * riskFactor),
      1.00,
      .65 + (.55 * riskFactor),
    ];

    final usedWeights = rawWeights.take(unique.length).toList();
    final weightSum = usedWeights.fold<double>(0, (a, b) => a + b);

    final allocations = <int>[];
    var allocated = 0;
    for (var i = 0; i < usedWeights.length; i++) {
      final value = i == usedWeights.length - 1
          ? 100 - allocated
          : ((usedWeights[i] / weightSum) * 100).round();
      allocations.add(value);
      allocated += value;
    }

    final bandHalf = math.max(atr * .10, currentPrice * .0015).toDouble();

    final steps = <CrocScaleInStep>[];
    for (var i = 0; i < unique.length; i++) {
      final anchor = unique[i];
      final low = math.max(minAllowed, anchor - bandHalf).toDouble();
      final high = math.max(low, anchor + bandHalf).toDouble();

      steps.add(
        CrocScaleInStep(
          index: i + 1,
          low: low,
          high: high,
          allocationPercent: allocations[i],
        ),
      );
    }

    final firstStep = steps.first;
    final status = currentPrice > firstStep.high * 1.015
        ? 'KOVALAMA • İLK KADEMEYİ BEKLE'
        : firstStep.contains(currentPrice)
        ? '1. KADEME UYGUN'
        : currentPrice < firstStep.low
        ? 'DAHA ALT KADEMEYE YAKIN'
        : 'İLK KADEMEYİ BEKLE';

    return CrocScaleInPlan(
      steps: List.unmodifiable(steps),
      stop: stop,
      target: analysis.target,
      status: status,
    );
  }
}
