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

  // Complete two-sided net book: +80 and -80.
  const rows = [
    CrocParticipantFlow(participant: 'A', buyLots: 100, sellLots: 20),
    CrocParticipantFlow(participant: 'B', buyLots: 20, sellLots: 100),
  ];

  setUp(store.clear);
  tearDown(store.clear);

  test('accepts verified fresh complete AKD and normalizes ticker', () {
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
    expect(store.participants('thyao', asOf: now).length, 2);
    expect(report.topNetSeller?.participant, 'B');
  });

  test('rejects incomplete AKD net book before it reaches UI', () {
    expect(
      store.accept(
        symbol: 'THYAO',
        source: source(now),
        rows: const [
          CrocParticipantFlow(participant: 'A', buyLots: 100, sellLots: 20),
          CrocParticipantFlow(participant: 'B', buyLots: 20, sellLots: 70),
        ],
        asOf: now,
      ),
      isFalse,
    );
    expect(store.report('THYAO', asOf: now), isNull);
  });

  test('rejects KTLEV-like one-sided distorted AKD before it reaches UI', () {
    expect(
      store.accept(
        symbol: 'KTLEV',
        source: source(now),
        rows: const [
          CrocParticipantFlow(participant: 'QNB', buyLots: 173934, sellLots: 0),
          CrocParticipantFlow(participant: 'GARANTI', buyLots: 163159, sellLots: 0),
          CrocParticipantFlow(participant: 'MIDAS', buyLots: 136507, sellLots: 0),
          CrocParticipantFlow(participant: 'IS', buyLots: 0, sellLots: 473600),
        ],
        asOf: now,
      ),
      isFalse,
    );
    expect(store.report('KTLEV', asOf: now), isNull);
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
    expect(store.participants('THYAO', asOf: now), isEmpty);
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
