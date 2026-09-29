import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_institutional_flow_store.dart';
import 'package:mobile/core/signals/croc_institutional_strength_engine.dart';

void main() {
  final store = CrocInstitutionalFlowStore.instance;
  final now = DateTime.utc(2026, 9, 29, 12);

  CrocInstitutionalSource source(DateTime at, {bool authenticated = true}) =>
      CrocInstitutionalSource(
        provider: 'TEST_PROVIDER',
        observedAt: at,
        authenticated: authenticated,
      );

  const rows = [
    CrocParticipantFlow(participant: 'A', buyLots: 100, sellLots: 20),
    CrocParticipantFlow(participant: 'B', buyLots: 20, sellLots: 70),
  ];

  setUp(store.clear);
  tearDown(store.clear);

  test('accepts verified fresh AKD and normalizes ticker', () {
    expect(
      store.accept(
        symbol: ' thyao ',
        source: source(now.subtract(const Duration(minutes: 5))),
        rows: rows,
        asOf: now,
      ),
      isTrue,
    );
    final report = store.report('THYAO', asOf: now);
    expect(report, isNotNull);
    expect(report!.topNetBuyer?.participant, 'A');
    expect(report.topNetSeller?.participant, 'B');
  });

  test('does not overwrite newer snapshot with older provider data', () {
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now.subtract(const Duration(minutes: 5))),
        rows: rows,
        asOf: now,
      ),
      isTrue,
    );
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now.subtract(const Duration(minutes: 10))),
        rows: rows,
        asOf: now,
      ),
      isFalse,
    );
  });

  test('rejects unverified feed and stale snapshots', () {
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now, authenticated: false),
        rows: rows,
        asOf: now,
      ),
      isFalse,
    );
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now.subtract(const Duration(days: 2))),
        rows: rows,
        asOf: now,
      ),
      isFalse,
    );
    expect(store.report('THYAO', asOf: now), isNull);
  });

  test('a previously fresh snapshot expires', () {
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now),
        rows: rows,
        asOf: now,
      ),
      isTrue,
    );
    expect(
      store.report('THYAO', asOf: now.add(const Duration(days: 2))),
      isNull,
    );
  });

  test('invalid symbol and duplicate participant rows are rejected', () {
    expect(
      store.accept(
        symbol: 'THYAO.IS',
        source: source(now),
        rows: rows,
        asOf: now,
      ),
      isFalse,
    );
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now),
        rows: const [
          CrocParticipantFlow(participant: 'A', buyLots: 1, sellLots: 2),
          CrocParticipantFlow(participant: 'a', buyLots: 3, sellLots: 4),
        ],
        asOf: now,
      ),
      isFalse,
    );
  });
}
