import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_matriks_akd_adapter.dart';
import 'package:mobile/core/signals/croc_institutional_flow_store.dart';
import 'package:mobile/core/signals/croc_institutional_strength_engine.dart';

void main() {
  final store = CrocInstitutionalFlowStore.instance;
  const adapter = CrocMatriksAkdAdapter();
  final now = DateTime.utc(2026, 9, 30, 12);

  CrocInstitutionalSource source({bool authenticated = true}) =>
      CrocInstitutionalSource(
        provider: 'MATRIKS_MANUAL_EXPORT',
        observedAt: now.subtract(const Duration(minutes: 5)),
        authenticated: authenticated,
      );

  setUp(store.clear);
  tearDown(store.clear);

  test('imports complete two-sided Matriks AKD end to end', () {
    final ok = adapter.import(
      symbol: ' thyao ',
      table: [
        ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
        ['YAPI KREDI',7701159,288.696,5358781,288.693,13059940,18.935,2342378,288.704],
        ['DENIZ',991777,289.2,3334155,289.8,4325932,6,-2342378,289.796],
      ],
      source: source(),
      asOf: now,
      store: store,
    );

    expect(ok, isTrue);
    final report = store.report('THYAO', asOf: now);
    expect(report, isNotNull);
    expect(report!.source.provider, 'MATRIKS_MANUAL_EXPORT');
    expect(report.topNetBuyer?.participant, 'YAPI KREDI');
    expect(report.topNetSeller?.participant, 'DENIZ');
  });

  test('KTLEV-like one-sided Matriks export never reaches store', () {
    final ok = adapter.import(
      symbol: 'KTLEV',
      table: [
        ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
        ['QNB YATIRIM',173934,9.61,0,0,173934,30,173934,9.61],
        ['GARANTI',163159,9.61,0,0,163159,28,163159,9.61],
        ['MIDAS',136507,9.61,0,0,136507,24,136507,9.61],
        ['IS',0,0,473600,9.61,473600,18,-473600,9.61],
      ],
      source: source(),
      asOf: now,
      store: store,
    );

    expect(ok, isFalse);
    expect(store.report('KTLEV', asOf: now), isNull);
  });

  test('partial Matriks export never reaches store', () {
    final ok = adapter.import(
      symbol: 'PASEU',
      table: [
        ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
        ['BUYER A',900,10,100,10,1000,50,800,10],
        ['SELLER A',50,10,150,10,200,5,-100,10],
      ],
      source: source(),
      asOf: now,
      store: store,
    );

    expect(ok, isFalse);
    expect(store.report('PASEU', asOf: now), isNull);
  });

  test('unauthenticated provenance cannot be imported', () {
    final ok = adapter.import(
      symbol: 'THYAO',
      table: [
        ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
        ['BUYER',900,10,100,10,1000,50,800,10],
        ['SELLER',100,10,900,10,1000,50,-800,10],
      ],
      source: source(authenticated: false),
      asOf: now,
      store: store,
    );

    expect(ok, isFalse);
    expect(store.report('THYAO', asOf: now), isNull);
  });
}
