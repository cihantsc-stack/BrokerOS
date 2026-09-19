import '../models/broker_flow.dart';
import '../models/institutional_flow_snapshot.dart';
import 'broker_distribution_engine.dart';
import 'concentration_engine.dart';
import 'foreign_ratio_engine.dart';
import 'fund_flow_engine.dart';
import 'institutional_score_engine.dart';
import 'lot_lock_engine.dart';

class InstitutionalFlowEngine {
  InstitutionalFlowEngine._();

  static final InstitutionalFlowEngine instance = InstitutionalFlowEngine._();

  final BrokerDistributionEngine _brokerEngine =
      const BrokerDistributionEngine();

  final ForeignRatioEngine _foreignEngine = const ForeignRatioEngine();

  final FundFlowEngine _fundEngine = const FundFlowEngine();

  final LotLockEngine _lotLockEngine = const LotLockEngine();

  final ConcentrationEngine _concentrationEngine = const ConcentrationEngine();

  final InstitutionalScoreEngine _scoreEngine =
      const InstitutionalScoreEngine();

  Future<InstitutionalFlowSnapshot> analyze(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));

    final List<BrokerFlow> brokers = _brokerEngine.build(symbol);

    final double foreignRatio = _foreignEngine.calculate(symbol);

    final double fundFlow = _fundEngine.calculate(symbol);

    final double lotLockRatio = _lotLockEngine.calculate(symbol);

    final double concentrationRatio = _concentrationEngine.calculate(brokers);

    final activeLayers = <String>[
      if (brokers.isNotEmpty) 'Kurum dağılımı',
      if (foreignRatio > 0) 'Yabancı oranı',
      if (fundFlow != 0) 'Fon akışı',
      if (lotLockRatio > 0) 'Lot kilidi',
      if (concentrationRatio > 0) 'Kurum yoğunluğu',
    ];

    final missingLayers = <String>[
      if (brokers.isEmpty) 'Kurum dağılımı',
      if (foreignRatio <= 0) 'Yabancı oranı',
      if (fundFlow == 0) 'Fon akışı',
      if (lotLockRatio <= 0) 'Lot kilidi',
      if (concentrationRatio <= 0) 'Kurum yoğunluğu',
    ];

    final InstitutionalScoreResult scoreResult = _scoreEngine.calculate(
      brokers: brokers,
      foreignRatio: foreignRatio,
      fundFlow: fundFlow,
      lotLockRatio: lotLockRatio,
      concentrationRatio: concentrationRatio,
    );

    final double totalNetLot = brokers.fold<double>(
      0,
      (double sum, BrokerFlow item) => sum + item.netLot,
    );

    final double totalNetValue = brokers.fold<double>(
      0,
      (double sum, BrokerFlow item) => sum + item.netValue,
    );

    return InstitutionalFlowSnapshot(
      symbol: symbol,
      direction: scoreResult.direction,
      score: scoreResult.score,
      totalNetLot: totalNetLot,
      totalNetValue: totalNetValue,
      foreignRatio: foreignRatio,
      fundFlow: fundFlow,
      lotLockRatio: lotLockRatio,
      concentrationRatio: concentrationRatio,
      topBrokers: brokers,
      activeLayers: List<String>.unmodifiable(activeLayers),
      missingLayers: List<String>.unmodifiable(missingLayers),
      generatedAt: DateTime.now(),
    );
  }
}
