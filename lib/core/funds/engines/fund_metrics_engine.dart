import 'dart:math' as math;

import '../models/fund_history_result.dart';
import '../models/fund_metrics_result.dart';
import '../models/fund_price_point.dart';

class FundMetricsEngine {
  const FundMetricsEngine();

  FundMetricsResult calculate(FundHistoryResult history) {
    if (!history.available || history.prices.length < 2) {
      return const FundMetricsResult.dataWaiting();
    }

    final prices = List<FundPricePoint>.from(history.prices)
      ..sort((a, b) => a.date.compareTo(b.date));

    final latest = prices.last;

    final return1M = _periodReturn(prices, latest, const Duration(days: 30));
    final return3M = _periodReturn(prices, latest, const Duration(days: 90));
    final return6M = _periodReturn(prices, latest, const Duration(days: 180));
    final return1Y = _periodReturn(prices, latest, const Duration(days: 365));

    final dailyReturns = <double>[];

    for (var i = 1; i < prices.length; i++) {
      final previous = prices[i - 1].price;
      final current = prices[i].price;

      if (previous > 0 && current > 0) {
        dailyReturns.add((current / previous) - 1.0);
      }
    }

    final annualizedVolatility = _annualizedVolatility(dailyReturns);
    final maxDrawdown = _maxDrawdown(prices);
    final riskLevel = _riskLevel(
      annualizedVolatility: annualizedVolatility,
      maxDrawdown: maxDrawdown,
    );

    return FundMetricsResult(
      available: true,
      status: 'GERCEK TEFAS FIYAT SERISINDEN HESAPLANDI',
      return1M: return1M,
      return3M: return3M,
      return6M: return6M,
      return1Y: return1Y,
      annualizedVolatility: annualizedVolatility,
      maxDrawdown: maxDrawdown,
      riskLevel: riskLevel,
      observationCount: prices.length,
    );
  }

  double? _periodReturn(
    List<FundPricePoint> prices,
    FundPricePoint latest,
    Duration lookback,
  ) {
    final targetDate = latest.date.subtract(lookback);

    FundPricePoint? anchor;

    for (final point in prices) {
      if (!point.date.isAfter(targetDate)) {
        anchor = point;
      } else {
        break;
      }
    }

    if (anchor == null || anchor.price <= 0) {
      return null;
    }

    return ((latest.price / anchor.price) - 1.0) * 100.0;
  }

  double? _annualizedVolatility(List<double> returns) {
    if (returns.length < 2) {
      return null;
    }

    final mean = returns.reduce((a, b) => a + b) / returns.length.toDouble();

    var squaredDiffSum = 0.0;

    for (final value in returns) {
      final diff = value - mean;
      squaredDiffSum += diff * diff;
    }

    final variance = squaredDiffSum / (returns.length - 1).toDouble();

    final dailyStdDev = math.sqrt(variance);

    return dailyStdDev * math.sqrt(252.0) * 100.0;
  }

  double? _maxDrawdown(List<FundPricePoint> prices) {
    if (prices.isEmpty) {
      return null;
    }

    var peak = prices.first.price;
    var worst = 0.0;

    for (final point in prices) {
      if (point.price > peak) {
        peak = point.price;
      }

      if (peak <= 0) {
        continue;
      }

      final drawdown = ((point.price / peak) - 1.0) * 100.0;

      if (drawdown < worst) {
        worst = drawdown;
      }
    }

    return worst;
  }

  String _riskLevel({
    required double? annualizedVolatility,
    required double? maxDrawdown,
  }) {
    if (annualizedVolatility == null || maxDrawdown == null) {
      return 'VERI BEKLENIYOR';
    }

    final drawdownAbs = maxDrawdown.abs();

    if (annualizedVolatility >= 40 || drawdownAbs >= 30) {
      return 'YUKSEK';
    }

    if (annualizedVolatility >= 20 || drawdownAbs >= 15) {
      return 'ORTA';
    }

    return 'DUSUK';
  }
}
