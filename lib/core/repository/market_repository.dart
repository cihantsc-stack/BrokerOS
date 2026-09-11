import '../models/market_snapshot.dart';

abstract class MarketRepository {
  MarketSnapshot getTodaySnapshot();
}
