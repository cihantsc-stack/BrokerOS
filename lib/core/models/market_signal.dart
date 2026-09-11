enum SignalType { trend, momentum, volume, smartMoney, institutional, news }

class MarketSignal {
  final SignalType type;
  final String title;
  final int score;
  final String description;

  const MarketSignal({
    required this.type,
    required this.title,
    required this.score,
    required this.description,
  });
}
