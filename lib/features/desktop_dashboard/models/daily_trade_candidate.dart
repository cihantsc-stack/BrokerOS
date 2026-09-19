import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/trade/croc_scale_in_engine.dart';

class DailyTradeCandidate {
  final String symbol;
  final String company;
  final String sector;
  final double livePrice;
  final double changePercent;
  final CrocTechnicalAnalysis analysis;
  final int tradeScore;
  final int sectorScore;
  final int globalScore;
  final int crocScore;
  final String tradeReason;
  final String contextLabel;

  // CROC Para Radari V2 - 5 dakika canli teyit
  final int moneyScore;
  final int memoryScore;
  final int overboughtScore;
  final double moneyVolumeRatio;
  final double moneyVolume15Ratio;
  final double moneyTlVolume;
  final double moneyCmf;
  final double moneyVwap;
  final double moneyRsi;
  final bool moneyRadarAvailable;

  const DailyTradeCandidate({
    required this.symbol,
    required this.company,
    required this.sector,
    required this.livePrice,
    required this.changePercent,
    required this.analysis,
    required this.tradeScore,
    required this.sectorScore,
    required this.globalScore,
    required this.crocScore,
    required this.tradeReason,
    required this.contextLabel,
    this.moneyScore = 0,
    this.memoryScore = 0,
    this.overboughtScore = 0,
    this.moneyVolumeRatio = 0,
    this.moneyVolume15Ratio = 0,
    this.moneyTlVolume = 0,
    this.moneyCmf = 0,
    this.moneyVwap = 0,
    this.moneyRsi = 0,
    this.moneyRadarAvailable = false,
  });

  double get support => analysis.support;
  double get resistance => analysis.resistance;
  double get stop => analysis.stop;
  double get target => analysis.target;
  int get technicalScore => analysis.score;
  String get trend => analysis.trend;
  String get risk => analysis.risk;
  double get riskReward => analysis.riskReward;
  double get volumeRatio => analysis.volumeRatio;

  CrocScaleInPlan get scaleInPlan =>
      CrocScaleInEngine.build(currentPrice: livePrice, analysis: analysis);

  DailyTradeCandidate copyWith({
    int? sectorScore,
    int? globalScore,
    int? crocScore,
    String? contextLabel,
    int? moneyScore,
    int? memoryScore,
    int? overboughtScore,
    double? moneyVolumeRatio,
    double? moneyVolume15Ratio,
    double? moneyTlVolume,
    double? moneyCmf,
    double? moneyVwap,
    double? moneyRsi,
    bool? moneyRadarAvailable,
  }) {
    return DailyTradeCandidate(
      symbol: symbol,
      company: company,
      sector: sector,
      livePrice: livePrice,
      changePercent: changePercent,
      analysis: analysis,
      tradeScore: tradeScore,
      sectorScore: sectorScore ?? this.sectorScore,
      globalScore: globalScore ?? this.globalScore,
      crocScore: crocScore ?? this.crocScore,
      tradeReason: tradeReason,
      contextLabel: contextLabel ?? this.contextLabel,
      moneyScore: moneyScore ?? this.moneyScore,
      memoryScore: memoryScore ?? this.memoryScore,
      overboughtScore: overboughtScore ?? this.overboughtScore,
      moneyVolumeRatio: moneyVolumeRatio ?? this.moneyVolumeRatio,
      moneyVolume15Ratio: moneyVolume15Ratio ?? this.moneyVolume15Ratio,
      moneyTlVolume: moneyTlVolume ?? this.moneyTlVolume,
      moneyCmf: moneyCmf ?? this.moneyCmf,
      moneyVwap: moneyVwap ?? this.moneyVwap,
      moneyRsi: moneyRsi ?? this.moneyRsi,
      moneyRadarAvailable: moneyRadarAvailable ?? this.moneyRadarAvailable,
    );
  }

  double get entryLow {
    final first = scaleInPlan.first;
    if (first != null) return first.low;

    final lower = support + analysis.atr * .10;
    final maxAllowed = livePrice * .995;
    if (lower <= 0) return livePrice;
    return lower > maxAllowed ? maxAllowed : lower;
  }

  double get entryHigh {
    final first = scaleInPlan.first;
    if (first != null) return first.high;

    final fromSupport = support + analysis.atr * .55;
    final cap = livePrice * 1.005;
    final value = fromSupport < cap ? fromSupport : cap;
    return value < entryLow ? entryLow : value;
  }
}
