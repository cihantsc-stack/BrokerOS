import 'institutional_order.dart';
import 'money_flow_point.dart';

class SmartMoneySnapshot {
  final String symbol;
  final List<InstitutionalOrder> institutions;
  final List<MoneyFlowPoint> moneyFlow;
  final double hiddenAccumulationScore;
  final double distributionRisk;
  final double largeOrderLots;
  final InstitutionalOrderSide largeOrderSide;
  final DateTime largeOrderTime;
  final String aiComment;

  const SmartMoneySnapshot({
    required this.symbol,
    required this.institutions,
    required this.moneyFlow,
    required this.hiddenAccumulationScore,
    required this.distributionRisk,
    required this.largeOrderLots,
    required this.largeOrderSide,
    required this.largeOrderTime,
    required this.aiComment,
  });
}
