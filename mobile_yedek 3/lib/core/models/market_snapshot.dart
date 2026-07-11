class MarketSnapshot {
  final double bist100;
  final double bist30;
  final double viop;

  final double moneyFlow;
  final double smartMoney;
  final double foreignRatio;
  final double fundFlow;

  final double volume;

  final double rsi;
  final double macd;

  final double ema20;
  final double ema50;
  final double ema200;

  final double newsScore;
  final double sentiment;

  final double volatility;

  const MarketSnapshot({
    required this.bist100,
    required this.bist30,
    required this.viop,
    required this.moneyFlow,
    required this.smartMoney,
    required this.foreignRatio,
    required this.fundFlow,
    required this.volume,
    required this.rsi,
    required this.macd,
    required this.ema20,
    required this.ema50,
    required this.ema200,
    required this.newsScore,
    required this.sentiment,
    required this.volatility,
  });
}