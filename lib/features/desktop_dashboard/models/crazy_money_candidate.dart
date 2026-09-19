class CrazyMoneyCandidate {
  final String symbol;
  final String company;
  final String sector;

  final double livePrice;
  final double changePercent;

  /// CROC Crazy Money nihai skoru.
  final int crazyScore;

  /// Para Radarı V2/V3 skorları.
  final int moneyScore;
  final int memoryScore;
  final int overboughtScore;

  /// Intraday para/hacim verileri.
  final double volumeRatio;
  final double volume15Ratio;
  final double tlVolume;
  final double cmf;
  final double vwap;
  final double rsi;

  /// Memory V2/V3 detayları.
  final double memory30MaxRatio;
  final double memory60MaxRatio;
  final int memory30MinutesAgo;
  final int memory60MinutesAgo;
  final double memory30PriceHold;
  final double memory60PriceHold;

  /// Para hareketinin kısa açıklaması.
  final String reason;

  const CrazyMoneyCandidate({
    required this.symbol,
    required this.company,
    required this.sector,
    required this.livePrice,
    required this.changePercent,
    required this.crazyScore,
    required this.moneyScore,
    required this.memoryScore,
    required this.overboughtScore,
    required this.volumeRatio,
    required this.volume15Ratio,
    required this.tlVolume,
    required this.cmf,
    required this.vwap,
    required this.rsi,
    required this.memory30MaxRatio,
    required this.memory60MaxRatio,
    required this.memory30MinutesAgo,
    required this.memory60MinutesAgo,
    required this.memory30PriceHold,
    required this.memory60PriceHold,
    required this.reason,
  });

  bool get aboveVwap => vwap > 0 && livePrice >= vwap;

  double get bestMemoryRatio => memory30MaxRatio >= memory60MaxRatio
      ? memory30MaxRatio
      : memory60MaxRatio;

  double get bestPriceHold => memory30MaxRatio >= memory60MaxRatio
      ? memory30PriceHold
      : memory60PriceHold;
}
