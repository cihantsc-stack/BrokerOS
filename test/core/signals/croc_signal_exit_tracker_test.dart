import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_signal_exit_tracker.dart';
import 'package:mobile/core/signals/croc_signal_memory_engine.dart';

void main() {
  final time = DateTime.utc(2026, 9, 28, 10);
  final signal = CrocSignalSnapshot(
    id: 'TEST-1',
    symbol: 'TEST',
    engine: 'CROC',
    createdAt: time,
    entryPrice: 100,
    score: 70,
    targetPrice: 105,
    stopPrice: 97,
  );
  CrocSignalObservation bar(int minutes, double high, double low, double close) =>
      CrocSignalObservation(
        observedAt: time.add(Duration(minutes: minutes)),
        high: high,
        low: low,
        close: close,
      );
  const tracker = CrocSignalExitTracker();

  test('first stop is preserved even when a later bar reaches target', () {
    final result = tracker.evaluate(signal, [
      bar(10, 110, 99, 105),
      bar(5, 101, 96, 98),
    ]);
    expect(result.type, CrocSignalExitType.stop);
    expect(result.level, 97);
  });

  test('same-bar target and stop is ambiguous, never a guaranteed win', () {
    final result = tracker.evaluate(signal, [bar(5, 106, 96, 100)]);
    expect(result.type, CrocSignalExitType.ambiguous);
    expect(result.level, isNull);
  });

  test('ignores pre-signal observations', () {
    final result = tracker.evaluate(signal, [
      bar(-5, 120, 90, 100),
      bar(5, 102, 99, 100),
    ]);
    expect(result.type, CrocSignalExitType.open);
  });

  test('target-only observation marks target', () {
    final result = tracker.evaluate(signal, [bar(5, 106, 99, 105)]);
    expect(result.type, CrocSignalExitType.target);
    expect(result.level, 105);
  });
  test('invalid long-side target or stop cannot produce a trade exit', () {
    final invalid = CrocSignalSnapshot(
      id: 'INVALID',
      symbol: 'TEST',
      engine: 'CROC',
      createdAt: time,
      entryPrice: 100,
      score: 70,
      targetPrice: 95,
      stopPrice: 105,
    );
    final result = tracker.evaluate(invalid, [bar(5, 110, 90, 100)]);
    expect(result.type, CrocSignalExitType.open);
    expect(result.occurredAt, isNull);
  });

  test('no target or stop never fabricates an exit', () {
    final missing = CrocSignalSnapshot(
      id: 'MISSING',
      symbol: 'TEST',
      engine: 'CROC',
      createdAt: time,
      entryPrice: 100,
      score: 70,
    );
    expect(
      tracker.evaluate(missing, [bar(5, 110, 90, 100)]).type,
      CrocSignalExitType.open,
    );
  });

  test('a later stop cannot replace the first confirmed target', () {
    final result = tracker.evaluate(signal, [
      bar(15, 101, 96, 98),
      bar(5, 106, 99, 105),
    ]);
    expect(result.type, CrocSignalExitType.target);
    expect(result.occurredAt, time.add(const Duration(minutes: 5)));
  });

}
