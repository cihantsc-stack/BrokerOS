import '../data_foundation/market/historical_candle.dart';

/// Same-clock 5-minute volume benchmark from completed historical sessions.
/// Volumes are exchange-reported candle units; no order-book inference.
class CrocLotAnomaly {
  final double currentLots;
  final double averageLots;
  final double ratio;
  final int referenceSessions;

  const CrocLotAnomaly({
    required this.currentLots,
    required this.averageLots,
    required this.ratio,
    required this.referenceSessions,
  });
}

class CrocLotAnomalyEngine {
  const CrocLotAnomalyEngine();

  /// Returns null when the historical same-slot sample is insufficient.
  /// No artificial ratio is returned for missing data.
  CrocLotAnomaly? evaluate(
    List<HistoricalCandle> candles, {
    int minSessions = 3,
    int maxSessions = 20,
  }) {
    if (candles.isEmpty || minSessions < 1 || maxSessions < minSessions) {
      return null;
    }

    final valid = candles.where((c) => c.volume > 0).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    if (valid.isEmpty) return null;

    final latest = valid.last;
    final time = latest.time;
    final volumes = <double>[];
    final sessionDates = <String>{};

    for (var i = valid.length - 2; i >= 0; i--) {
      final candle = valid[i];
      final date = '${candle.time.year}-${candle.time.month}-${candle.time.day}';
      if (candle.time.year == time.year &&
          candle.time.month == time.month &&
          candle.time.day == time.day) {
        continue;
      }
      if (candle.time.hour != time.hour ||
          candle.time.minute != time.minute ||
          sessionDates.contains(date)) {
        continue;
      }

      sessionDates.add(date);
      volumes.add(candle.volume.toDouble());
      if (volumes.length >= maxSessions) break;
    }

    if (volumes.length < minSessions) return null;
    final average = volumes.reduce((a, b) => a + b) / volumes.length;
    if (average <= 0) return null;

    return CrocLotAnomaly(
      currentLots: latest.volume.toDouble(),
      averageLots: average,
      ratio: latest.volume / average,
      referenceSessions: volumes.length,
    );
  }
}
