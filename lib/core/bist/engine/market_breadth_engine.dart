import '../models/bist_stock_tick.dart';
import '../models/market_breadth.dart';

class MarketBreadthEngine {
  const MarketBreadthEngine();

  MarketBreadth calculate(List<BistStockTick> ticks) {
    if (ticks.isEmpty) {
      return const MarketBreadth(
        total: 0,
        rising: 0,
        falling: 0,
        flat: 0,
        averageChange: 0,
        risingRatio: 0,
        fallingRatio: 0,
        score: 50,
      );
    }

    final int rising = ticks
        .where((BistStockTick tick) => tick.isRising)
        .length;
    final int falling = ticks
        .where((BistStockTick tick) => tick.isFalling)
        .length;
    final int flat = ticks.length - rising - falling;

    final double averageChange =
        ticks.fold<double>(
          0,
          (double sum, BistStockTick tick) => sum + tick.changePercent,
        ) /
        ticks.length;

    final double risingRatio = rising / ticks.length;
    final double fallingRatio = falling / ticks.length;
    final double rawScore =
        50 + ((risingRatio - fallingRatio) * 45) + (averageChange * 5);

    return MarketBreadth(
      total: ticks.length,
      rising: rising,
      falling: falling,
      flat: flat,
      averageChange: averageChange,
      risingRatio: risingRatio,
      fallingRatio: fallingRatio,
      score: rawScore.round().clamp(0, 100),
    );
  }
}
