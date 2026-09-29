import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_signal_memory_engine.dart';
import 'package:mobile/core/signals/croc_signal_exit_tracker.dart';
import 'package:mobile/core/signals/croc_signal_memory_ledger.dart';

void main() {
  final start = DateTime.utc(2026, 9, 28, 10);
  CrocSignalSnapshot signal({String id = 'AKBNK-20260928-1000'}) =>
      CrocSignalSnapshot(
        id: id,
        symbol: 'AKBNK',
        engine: 'CRAZY_MONEY',
        createdAt: start,
        entryPrice: 100,
        score: 75,
        targetPrice: 105,
        stopPrice: 97,
      );

  CrocSignalObservation point(int minute, double high, double low, double close) =>
      CrocSignalObservation(
        observedAt: start.add(Duration(minutes: minute)),
        high: high,
        low: low,
        close: close,
      );

  test('freezes original signal and rejects duplicate IDs', () {
    final ledger = CrocSignalMemoryLedger();
    expect(ledger.recordSignal(signal()), isTrue);
    expect(ledger.recordSignal(signal()), isFalse);
    expect(ledger.signal('AKBNK-20260928-1000')!.score, 75);
    expect(ledger.signalCount, 1);
  });

  test('rejects observations before signal, invalid data and duplicate times', () {
    final ledger = CrocSignalMemoryLedger();
    expect(ledger.recordSignal(signal()), isTrue);
    expect(ledger.recordObservation('unknown', point(5, 101, 99, 100)), isFalse);
    expect(ledger.recordObservation(signal().id, point(-1, 101, 99, 100)), isFalse);
    expect(ledger.recordObservation(signal().id, point(5, 99, 101, 100)), isFalse);
    expect(ledger.recordObservation(signal().id, point(5, 106, 98, 104)), isTrue);
    expect(ledger.recordObservation(signal().id, point(5, 200, 1, 150)), isFalse);
    final result = ledger.outcome(signal().id, CrocSignalHorizon.minutes5);
    expect(result?.returnPercent, closeTo(4, 0.0001));
    expect(result?.targetTouched, isTrue);
    expect(result?.stopTouched, isFalse);
  });

  test('later observations do not rewrite earlier horizon results', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(5, 102, 99, 101));
    final original = ledger.outcome(signal().id, CrocSignalHorizon.minutes5);
    ledger.recordObservation(signal().id, point(15, 115, 90, 110));
    final after = ledger.outcome(signal().id, CrocSignalHorizon.minutes5);
    expect(after?.returnPercent, original?.returnPercent);
    expect(after?.targetTouched, isFalse);
    expect(ledger.outcome(signal().id, CrocSignalHorizon.minutes15)?.targetTouched, isTrue);
  });
  test('ledger exposes first stop without turning later target into success', () {
    final ledger = CrocSignalMemoryLedger();
    expect(ledger.firstExit('unknown'), isNull);
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(5, 101, 96, 98));
    ledger.recordObservation(signal().id, point(15, 110, 99, 108));
    final exit = ledger.firstExit(signal().id);
    expect(exit?.type, CrocSignalExitType.stop);
    expect(exit?.level, 97);
  });

  test('ledger reports ambiguous when target and stop share a bar', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(5, 106, 96, 100));
    expect(
      ledger.firstExit(signal().id)?.type,
      CrocSignalExitType.ambiguous,
    );
  });

  test('does not infer a 5-minute result from a 4-minute quote', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(4, 104, 104, 104));
    expect(ledger.outcome(signal().id, CrocSignalHorizon.minutes5), isNull);
    ledger.recordObservation(signal().id, point(7, 103, 103, 103));
    expect(
      ledger.outcome(signal().id, CrocSignalHorizon.minutes5)?.returnPercent,
      closeTo(3, 0.0001),
    );
  });

  test('does not substitute a quote outside the 5-minute grace window', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(11, 105, 105, 105));
    expect(ledger.outcome(signal().id, CrocSignalHorizon.minutes5), isNull);
  });

  test('15 and 60 minute horizons require their own later samples', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(5, 101, 101, 101));
    expect(ledger.outcome(signal().id, CrocSignalHorizon.minutes15), isNull);
    expect(ledger.outcome(signal().id, CrocSignalHorizon.hour1), isNull);
    ledger.recordObservation(signal().id, point(16, 102, 102, 102));
    expect(
      ledger.outcome(signal().id, CrocSignalHorizon.minutes15)?.returnPercent,
      closeTo(2, 0.0001),
    );
    expect(ledger.outcome(signal().id, CrocSignalHorizon.hour1), isNull);
    ledger.recordObservation(signal().id, point(61, 104, 104, 104));
    expect(
      ledger.outcome(signal().id, CrocSignalHorizon.hour1)?.returnPercent,
      closeTo(4, 0.0001),
    );
  });

  test('session-close result is absent without close confirmation', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(60, 103, 103, 103));
    expect(
      ledger.outcome(signal().id, CrocSignalHorizon.sessionClose),
      isNull,
    );
  });

  test('out-of-order scanner samples still use earliest eligible quote', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(9, 109, 109, 109));
    ledger.recordObservation(signal().id, point(6, 102, 102, 102));
    ledger.recordObservation(signal().id, point(4, 120, 120, 120));
    final outcome = ledger.outcome(signal().id, CrocSignalHorizon.minutes5);
    expect(outcome?.evaluatedAt, start.add(const Duration(minutes: 6)));
    expect(outcome?.returnPercent, closeTo(2, 0.0001));
    expect(outcome?.maxFavorablePercent, closeTo(20, 0.0001));
  });

  test('a missing 5-minute sample stays unknown despite a later 15-minute quote', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(15, 106, 106, 106));
    expect(ledger.outcome(signal().id, CrocSignalHorizon.minutes5), isNull);
    expect(
      ledger.outcome(signal().id, CrocSignalHorizon.minutes15)?.returnPercent,
      closeTo(6, 0.0001),
    );
  });

  test('confirmed session close uses the latest valid observed quote', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    ledger.recordObservation(signal().id, point(60, 103, 103, 103));
    ledger.recordObservation(signal().id, point(120, 107, 107, 107));
    final close = ledger.outcome(
      signal().id,
      CrocSignalHorizon.sessionClose,
      sessionClosed: true,
    );
    expect(close?.evaluatedAt, start.add(const Duration(minutes: 120)));
    expect(close?.returnPercent, closeTo(7, 0.0001));
  });

  test('duplicate observations cannot revise the recorded close', () {
    final ledger = CrocSignalMemoryLedger();
    ledger.recordSignal(signal());
    expect(
      ledger.recordObservation(signal().id, point(120, 102, 102, 102)),
      isTrue,
    );
    expect(
      ledger.recordObservation(signal().id, point(120, 110, 110, 110)),
      isFalse,
    );
    final close = ledger.outcome(
      signal().id,
      CrocSignalHorizon.sessionClose,
      sessionClosed: true,
    );
    expect(close?.returnPercent, closeTo(2, 0.0001));
  });

}
