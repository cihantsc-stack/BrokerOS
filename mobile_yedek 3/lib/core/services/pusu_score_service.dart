import '../models/market_snapshot.dart';

class PusuScoreService {
  static int calculate(MarketSnapshot data) {
    int score = 0;

    score += (data.moneyFlow * 3).round();

    score += (data.smartMoney * 3).round();

    score += (data.foreignRatio / 5).round();

    score += (data.newsScore / 8).round();

    score += (data.sentiment / 8).round();

    score += data.rsi > 55 ? 8 : 0;

    score += data.macd > 0 ? 8 : 0;

    if (score > 100) score = 100;

    return score;
  }
}