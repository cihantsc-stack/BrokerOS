import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_signal_memory_engine.dart';

void main() {
  final start = DateTime.utc(2026, 9, 28, 10);
  final signal = CrocSignalSnapshot(
    id: 'OSTIM-1',
    symbol: 'OSTIM',
    engine: 'CRAZY_MONEY',
    createdAt: start,
    entryPrice: 100,
    score: 70,
    targetPrice: 105,
    stopPrice: 97,
  );
  CrocSignalObservation observation(int minute, double high, double low,
          double close) =>
      CrocSignalObservation(
        observedAt: start.add(Duration(minutes: minute)),
        high: high,
        low: low,
        close: close,
      );

  const engine = CrocSignalMemoryEngine();

  test('5-minute outcome uses only observations after signal and until cutoff',
      () {
    final result = engine.evaluate(
      signal,
      [
        observation(-5, 999, 1, 200),
        observation(1, 103, 99, 102),
        observation(5, 106, 98, 104),
        observation(6, 200, 50, 150),
      ],
      horizon: CrocSignalHorizon.minutes5,
    );

    expect(result, isNotNull);
    expect(result!.closePrice, 104);
    expect(result.returnPercent, closeTo(4, 0.0001));
    expect(result.maxFavorablePercent, closeTo(6, 0.0001));
    expect(result.maxAdversePercent, closeTo(-2, 0.0001));
    expect(result.targetTouched, isTrue);
    expect(result.stopTouched, isFalse);
  });

  test('does not score horizon before its observation arrives', () {
    expect(
      engine.evaluate(
        signal,
        [observation(4, 101, 99, 100)],
        horizon: CrocSignalHorizon.minutes5,
      ),
      isNull,
    );
  });

  test('session close requires explicit confirmation', () {
    final observations = [observation(5, 101, 98, 100)];
    expect(
      engine.evaluate(
        signal,
        observations,
        horizon: CrocSignalHorizon.sessionClose,
      ),
      isNull,
    );
    expect(
      engine.evaluate(
        signal,
        observations,
        horizon: CrocSignalHorizon.sessionClose,
        sessionClosed: true,
      )?.closePrice,
      100,
    );
  });

  test('invalid observations cannot create artificial outcomes', () {
    expect(
      engine.evaluate(
        signal,
        [observation(5, 99, 101, 100)],
        horizon: CrocSignalHorizon.minutes5,
      ),
      isNull,
    );
  });
}
