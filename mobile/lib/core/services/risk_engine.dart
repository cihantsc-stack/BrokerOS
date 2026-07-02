import '../models/market_snapshot.dart';

class RiskEngine {
  static String calculate(MarketSnapshot data) {
    if (data.volatility > 80) {
      return "Yüksek";
    }

    if (data.volatility > 60) {
      return "Orta";
    }

    return "Düşük";
  }
}