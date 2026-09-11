class MarketBreadth {
  final int total;
  final int rising;
  final int falling;
  final int flat;
  final double averageChange;
  final double risingRatio;
  final double fallingRatio;
  final int score;

  const MarketBreadth({
    required this.total,
    required this.rising,
    required this.falling,
    required this.flat,
    required this.averageChange,
    required this.risingRatio,
    required this.fallingRatio,
    required this.score,
  });

  String get healthLabel {
    if (score >= 75) return 'GÜÇLÜ';
    if (score >= 60) return 'POZİTİF';
    if (score >= 42) return 'KARIŞIK';
    if (score >= 25) return 'ZAYIF';
    return 'SERT NEGATİF';
  }
}
