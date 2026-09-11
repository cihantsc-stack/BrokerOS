import 'historical_candle.dart';

class CrocDataQualityResult {
  final int score;
  final double maxGapPercent;

  const CrocDataQualityResult({
    required this.score,
    required this.maxGapPercent,
  });

  bool get hasRisk => score < 95;
}

class CrocDataQualityEngine {
  const CrocDataQualityEngine._();

  static CrocDataQualityResult evaluate(
    List<HistoricalCandle> candles, {
    int lookback = 24,
  }) {
    if (candles.length < 2) {
      return const CrocDataQualityResult(score: 70, maxGapPercent: 0);
    }

    final start = candles.length > lookback ? candles.length - lookback : 0;
    final recent = candles.sublist(start);
    var maxGap = 0.0;

    for (var i = 1; i < recent.length; i++) {
      final previousClose = recent[i - 1].close;
      final currentOpen = recent[i].open;
      final currentClose = recent[i].close;

      if (previousClose <= 0 || currentOpen <= 0 || currentClose <= 0) {
        continue;
      }

      final openGap = (((currentOpen - previousClose) / previousClose) * 100)
          .abs();
      final closeGap = (((currentClose - previousClose) / previousClose) * 100)
          .abs();

      if (openGap > maxGap) maxGap = openGap;
      if (closeGap > maxGap) maxGap = closeGap;
    }

    final score = maxGap > 20
        ? 35
        : maxGap > 15
        ? 50
        : maxGap > 10.5
        ? 65
        : maxGap > 8
        ? 85
        : 100;

    return CrocDataQualityResult(score: score, maxGapPercent: maxGap);
  }
}
