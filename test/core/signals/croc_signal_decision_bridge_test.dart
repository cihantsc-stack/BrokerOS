import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_signal_decision_bridge.dart';
import 'package:mobile/core/signals/croc_signal_memory_engine.dart';
import 'package:mobile/core/signals/croc_signal_memory_ledger.dart';

void main() {
  final at = DateTime.utc(2026, 9, 29, 9);
  late CrocSignalMemoryLedger ledger;

  setUp(() => ledger = CrocSignalMemoryLedger());

  test('combines target/stop risk with forward-only memory', () {
    expect(
      ledger.recordSignal(CrocSignalSnapshot(
        id: 'THYAO-1',
        symbol: 'THYAO',
        engine: 'CRAZY',
        createdAt: at,
        entryPrice: 100,
        score: 78,
        targetPrice: 110,
        stopPrice: 95,
      )),
      isTrue,
    );
    expect(
      ledger.recordObservation(
        'THYAO-1',
        CrocSignalObservation(
          observedAt: at.add(const Duration(minutes: 6)),
          high: 103,
          low: 99,
          close: 102,
        ),
      ),
      isTrue,
    );
    final view = const CrocSignalDecisionBridge().inspect(ledger, 'THYAO-1');
    expect(view, isNotNull);
    expect(view!.riskPercent, 5);
    expect(view.rewardPercent, 10);
    expect(view.rewardRiskRatio, 2);
    expect(view.minutes5?.returnPercent, 2);
    expect(view.minutes15, isNull);
    expect(view.hour1, isNull);
  });

  test('missing target/stop does not fabricate risk or reward', () {
    ledger.recordSignal(CrocSignalSnapshot(
      id: 'THYAO-2',
      symbol: 'THYAO',
      engine: 'CRAZY',
      createdAt: at,
      entryPrice: 100,
      score: 70,
    ));
    final view = const CrocSignalDecisionBridge().inspect(ledger, 'THYAO-2');
    expect(view!.riskPercent, isNull);
    expect(view.rewardPercent, isNull);
    expect(view.rewardRiskRatio, isNull);
  });

  test('unknown signal returns no decision view', () {
    expect(
      const CrocSignalDecisionBridge().inspect(ledger, 'UNKNOWN'),
      isNull,
    );
  });
}
