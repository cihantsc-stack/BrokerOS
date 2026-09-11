class SectorStrength {
  final String sector;
  final int stockCount;
  final int rising;
  final int falling;
  final double averageChange;
  final double totalVolume;
  final int score;

  const SectorStrength({
    required this.sector,
    required this.stockCount,
    required this.rising,
    required this.falling,
    required this.averageChange,
    required this.totalVolume,
    required this.score,
  });
}
