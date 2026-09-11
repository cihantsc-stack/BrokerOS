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
