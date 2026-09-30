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
    expect(view!.riskPercent, closeTo(5, 0.0001));
    expect(view.rewardPercent, closeTo(10, 0.0001));
    expect(view.rewardRiskRatio, closeTo(2, 0.0001));
    expect(view.minutes5?.returnPercent, closeTo(2, 0.0001));
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
  test('invalid target and stop levels never produce risk or reward', () {
    ledger.recordSignal(CrocSignalSnapshot(
      id: 'THYAO-INVALID',
      symbol: 'THYAO',
      engine: 'CRAZY',
      createdAt: at,
      entryPrice: 100,
      score: 70,
      targetPrice: 95,
      stopPrice: 105,
    ));
    final view = const CrocSignalDecisionBridge().inspect(
      ledger,
      'THYAO-INVALID',
    );
    expect(view, isNotNull);
    expect(view!.riskPercent, isNull);
    expect(view.rewardPercent, isNull);
    expect(view.rewardRiskRatio, isNull);
  });

  test('valid risk without target does not fabricate a reward ratio', () {
    ledger.recordSignal(CrocSignalSnapshot(
      id: 'THYAO-STOP-ONLY',
      symbol: 'THYAO',
      engine: 'CRAZY',
      createdAt: at,
      entryPrice: 100,
      score: 70,
      stopPrice: 98,
    ));
    final view = const CrocSignalDecisionBridge().inspect(
      ledger,
      'THYAO-STOP-ONLY',
    );
    expect(view!.riskPercent, closeTo(2, 0.0001));
    expect(view.rewardPercent, isNull);
    expect(view.rewardRiskRatio, isNull);
  });

  test('a later quote cannot fill missing earlier decision horizons', () {
    const id = 'THYAO-SPARSE';
    ledger.recordSignal(CrocSignalSnapshot(
      id: id,
      symbol: 'THYAO',
      engine: 'CRAZY',
      createdAt: at,
      entryPrice: 100,
      score: 70,
    ));
    ledger.recordObservation(
      id,
      CrocSignalObservation(
        observedAt: at.add(const Duration(minutes: 16)),
        high: 104,
        low: 104,
        close: 104,
      ),
    );
    final view = const CrocSignalDecisionBridge().inspect(ledger, id);
    expect(view, isNotNull);
    expect(view!.minutes5, isNull);
    expect(view.minutes15?.returnPercent, closeTo(4, 0.0001));
    expect(view.hour1, isNull);
    expect(view.riskPercent, isNull);
    expect(view.rewardRiskRatio, isNull);
  });

  test('session close requires explicit confirmation', () {
    const id = 'CLOSE-1';
    ledger.recordSignal(CrocSignalSnapshot(
      id: id, symbol: 'THYAO', engine: 'CRAZY',
      createdAt: at, entryPrice: 100, score: 70,
    ));
    ledger.recordObservation(id, CrocSignalObservation(
      observedAt: at.add(const Duration(hours: 7)),
      high: 104, low: 100, close: 103,
    ));
    expect(
      const CrocSignalDecisionBridge().inspect(ledger, id)?.sessionClose,
      isNull,
    );
    expect(
      const CrocSignalDecisionBridge()
          .inspect(ledger, id, sessionClosed: true)
          ?.sessionClose
          ?.returnPercent,
      closeTo(3, 0.0001),
    );
  });

}
