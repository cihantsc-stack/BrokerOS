import '../models/market_snapshot.dart';
import 'market_repository.dart';

class MockMarketRepository implements MarketRepository {
  @override
  MarketSnapshot getTodaySnapshot() {
    return const MarketSnapshot(
      bist100: 1.42,
      bist30: 1.18,
      viop: 0.96,
      moneyFlow: 4.2,
      smartMoney: 3.8,
      foreignRatio: 56,
      fundFlow: 0.0,
      volume: 142.8,
      rsi: 61,
      macd: 1.2,
      ema20: 184,
      ema50: 178,
      ema200: 161,
      newsScore: 82,
      sentiment: 76,
      volatility: 48,
    );
  }
}
