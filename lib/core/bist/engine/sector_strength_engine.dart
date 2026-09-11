import 'dart:math' as math;

import '../models/bist_stock_tick.dart';
import '../models/sector_strength.dart';

class SectorStrengthEngine {
  const SectorStrengthEngine();

  List<SectorStrength> calculate(List<BistStockTick> ticks) {
    if (ticks.isEmpty) {
      return const <SectorStrength>[];
    }

    final Map<String, List<BistStockTick>> groups =
        <String, List<BistStockTick>>{};

    for (final BistStockTick tick in ticks) {
      groups.putIfAbsent(tick.stock.sector, () => <BistStockTick>[]).add(tick);
    }

    final List<_SectorMetrics> metrics = <_SectorMetrics>[];

    for (final MapEntry<String, List<BistStockTick>> entry in groups.entries) {
      final List<BistStockTick> sectorTicks = entry.value;

      final int rising = sectorTicks
          .where((BistStockTick tick) => tick.isRising)
          .length;

      final int falling = sectorTicks
          .where((BistStockTick tick) => tick.isFalling)
          .length;

      final double averageChange =
          sectorTicks.fold<double>(
            0,
            (double sum, BistStockTick tick) => sum + tick.changePercent,
          ) /
          sectorTicks.length;

      final double totalVolume = sectorTicks.fold<double>(
        0,
        (double sum, BistStockTick tick) => sum + tick.volume,
      );

      // Fiyat x hacim: çıplak lot hacmine göre sektörler arası
      // aktiviteyi daha anlamlı karşılaştırır.
      final double totalTurnover = sectorTicks.fold<double>(
        0,
        (double sum, BistStockTick tick) => sum + (tick.price * tick.volume),
      );

      final double averageTurnover = totalTurnover / sectorTicks.length;

      metrics.add(
        _SectorMetrics(
          sector: entry.key,
          stockCount: sectorTicks.length,
          rising: rising,
          falling: falling,
          averageChange: averageChange,
          totalVolume: totalVolume,
          averageTurnover: averageTurnover,
        ),
      );
    }

    final List<double> turnovers =
        metrics
            .map((item) => item.averageTurnover)
            .where((value) => value > 0)
            .toList()
          ..sort();

    final double medianTurnover = _median(turnovers);

    final List<SectorStrength> result = <SectorStrength>[];

    for (final _SectorMetrics item in metrics) {
      final double breadth = (item.rising - item.falling) / item.stockCount;

      // 15 - 85 bandı.
      final double breadthScore = 50 + (breadth * 35);

      // Günlük sektör momentumunu doygunlaştır.
      // ±2% civarı güçlü, ±4% sonrası puan artışı yavaşlar.
      final double momentumNormalized = _softBound(item.averageChange / 2.0);

      final double momentumScore = 50 + (momentumNormalized * 35);

      // Sektörün ortalama işlem aktivitesini medyana göre ölç.
      final double activityRatio = medianTurnover <= 0
          ? 1
          : item.averageTurnover / medianTurnover;

      final double activityNormalized = _logRatio(activityRatio);

      final double activityScore = 50 + (activityNormalized * 20);

      // Ana skor:
      // %45 piyasa yayılımı
      // %40 fiyat momentumu
      // %15 göreli işlem aktivitesi
      double score =
          (breadthScore * 0.45) +
          (momentumScore * 0.40) +
          (activityScore * 0.15);

      // Gerçekten güçlü eşzamanlı teyitlere sınırlı bonus.
      if (item.rising == item.stockCount && item.averageChange >= 1.5) {
        score += 3;
      }

      if (item.averageChange >= 2.5) {
        score += 2;
      }

      if (medianTurnover > 0 && item.averageTurnover >= medianTurnover * 1.5) {
        score += 2;
      }

      // Tek/az hisseli sektörlerin kolayca zirveye çıkmasını engelle.
      if (item.stockCount == 1) {
        score -= 8;
      } else if (item.stockCount == 2) {
        score -= 4;
      }

      result.add(
        SectorStrength(
          sector: item.sector,
          stockCount: item.stockCount,
          rising: item.rising,
          falling: item.falling,
          averageChange: item.averageChange,
          totalVolume: item.totalVolume,
          score: score.round().clamp(5, 94),
        ),
      );
    }

    result.sort(
      (SectorStrength a, SectorStrength b) => b.score.compareTo(a.score),
    );

    return result;
  }

  double _softBound(double value) {
    final double x = value.clamp(-6.0, 6.0);

    // tanh benzeri yumuşak sınır.
    final double e = math.exp(2 * x);
    return (e - 1) / (e + 1);
  }

  double _logRatio(double ratio) {
    if (ratio <= 0) return -1;

    final double raw = math.log(ratio) / math.log(4);

    return raw.clamp(-1.0, 1.0);
  }

  double _median(List<double> values) {
    if (values.isEmpty) return 0;

    final int middle = values.length ~/ 2;

    if (values.length.isOdd) {
      return values[middle];
    }

    return (values[middle - 1] + values[middle]) / 2;
  }
}

class _SectorMetrics {
  final String sector;
  final int stockCount;
  final int rising;
  final int falling;
  final double averageChange;
  final double totalVolume;
  final double averageTurnover;

  const _SectorMetrics({
    required this.sector,
    required this.stockCount,
    required this.rising,
    required this.falling,
    required this.averageChange,
    required this.totalVolume,
    required this.averageTurnover,
  });
}
