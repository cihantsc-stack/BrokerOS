import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_akd_historical_archive.dart';
import 'package:mobile/core/signals/croc_institutional_flow_store.dart';

void main() {
  const csv = 'participant,buy_lots,sell_lots\nA,100,20\nB,20,70\n';
  final date = DateTime.utc(2026, 9, 28);
  late CrocAkdHistoricalArchive archive;

  setUp(() {
    archive = CrocAkdHistoricalArchive();
    CrocInstitutionalFlowStore.instance.clear();
  });

  test('historical rows are indexed by ticker and trading day', () {
    expect(
      archive.importNormalizedCsv(
        symbol: ' thyao ',
        tradingDate: date,
        csv: csv,
      ),
      isTrue,
    );
    expect(archive.rows('THYAO', date).length, 2);
    expect(
      archive.rows('THYAO', date.add(const Duration(days: 1))),
      isEmpty,
    );
  });

  test('summarizes historical broker totals and net leaders', () {
    expect(
      archive.importNormalizedCsv(
        symbol: 'THYAO',
        tradingDate: date,
        csv: csv,
      ),
      isTrue,
    );
    final result = archive.summary('thyao', date);
    expect(result, isNotNull);
    expect(result!.participantCount, 2);
    expect(result.totalBuyLots, 120);
    expect(result.totalSellLots, 90);
    expect(result.netLots, 30);
    expect(result.topNetBuyer?.participant, 'A');
    expect(result.topNetSeller?.participant, 'B');
    expect(
      archive.summary('THYAO', date.add(const Duration(days: 1))),
      isNull,
    );
  });

  test('historical import does not produce a live verified AKD report', () {
    expect(
      archive.importNormalizedCsv(
        symbol: 'THYAO',
        tradingDate: date,
        csv: csv,
      ),
      isTrue,
    );
    expect(CrocInstitutionalFlowStore.instance.report('THYAO'), isNull);
  });

  test('invalid or duplicate broker rows are rejected', () {
    expect(
      archive.importNormalizedCsv(
        symbol: 'THYAO',
        tradingDate: date,
        csv: 'participant,buy_lots,sell_lots\nA,1,2\na,2,3',
      ),
      isFalse,
    );
    expect(archive.rows('THYAO', date), isEmpty);
  });
}
