import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_akd_decision_bridge.dart';
import 'package:mobile/core/akd/croc_akd_models.dart';

CrocAkdResult result({
  required CrocAkdConcentrationSignal signal,
  bool balanced = true,
  bool distorted = false,
}) {
  const row = CrocAkdBrokerRow(
    institution: 'TEST',
    buyLots: 100,
    buyAverage: 10,
    sellLots: 100,
    sellAverage: 10,
    totalLots: 200,
    sharePercent: 100,
    netLots: 0,
    cost: 10,
  );
  return CrocAkdResult(
    rows: const [row],
    topBuyers: const [],
    topSellers: const [],
    positiveNetLots: 0,
    negativeNetLots: 0,
    buyerConcentrationPercent: 0,
    sellerConcentrationPercent: 0,
    turnoverConcentrationPercent: 100,
    oneSidedTurnoverPercent: distorted ? 80 : 0,
    isFlowDistorted: distorted,
    isBalancedNetBook: balanced,
    netBookImbalancePercent: balanced ? 0 : 20,
    signal: signal,
  );
}

void main() {
  const bridge = CrocAkdDecisionBridge();

  test('rejects incomplete AKD before downstream scoring', () {
    final evidence = bridge.inspect(result(
      signal: CrocAkdConcentrationSignal.insufficientData,
      balanced: false,
    ));
    expect(evidence.isEligible, isFalse);
    expect(evidence.bias, CrocAkdDecisionBias.unavailable);
  });

  test('rejects one-sided distorted AKD before downstream scoring', () {
    final evidence = bridge.inspect(result(
      signal: CrocAkdConcentrationSignal.distorted,
      distorted: true,
    ));
    expect(evidence.isEligible, isFalse);
    expect(evidence.bias, CrocAkdDecisionBias.unavailable);
  });

  test('passes verified buyer concentration without adding a score', () {
    final evidence = bridge.inspect(result(
      signal: CrocAkdConcentrationSignal.buyerConcentrated,
    ));
    expect(evidence.isEligible, isTrue);
    expect(evidence.bias, CrocAkdDecisionBias.buyer);
  });

  test('passes verified seller concentration', () {
    final evidence = bridge.inspect(result(
      signal: CrocAkdConcentrationSignal.sellerConcentrated,
    ));
    expect(evidence.isEligible, isTrue);
    expect(evidence.bias, CrocAkdDecisionBias.seller);
  });

  test('keeps balanced AKD neutral', () {
    final evidence = bridge.inspect(result(
      signal: CrocAkdConcentrationSignal.balanced,
    ));
    expect(evidence.isEligible, isTrue);
    expect(evidence.bias, CrocAkdDecisionBias.neutral);
  });
}
