import 'broker_flow.dart';
import 'institutional_direction.dart';

class InstitutionalFlowSnapshot {
  final String symbol;
  final InstitutionalDirection direction;
  final double score;
  final double totalNetLot;
  final double totalNetValue;
  final double foreignRatio;
  final double fundFlow;
  final double lotLockRatio;
  final double concentrationRatio;
  final List<BrokerFlow> topBrokers;
  final List<String> activeLayers;
  final List<String> missingLayers;
  final DateTime generatedAt;

  const InstitutionalFlowSnapshot({
    required this.symbol,
    required this.direction,
    required this.score,
    required this.totalNetLot,
    required this.totalNetValue,
    required this.foreignRatio,
    required this.fundFlow,
    required this.lotLockRatio,
    required this.concentrationRatio,
    required this.topBrokers,
    required this.activeLayers,
    required this.missingLayers,
    required this.generatedAt,
  });

  bool get positive =>
      direction == InstitutionalDirection.strongBuy ||
      direction == InstitutionalDirection.buy;

  bool get hasRealData => activeLayers.isNotEmpty;

  int get coveragePercent =>
      ((activeLayers.length / 5) * 100).round().clamp(0, 100);
}
