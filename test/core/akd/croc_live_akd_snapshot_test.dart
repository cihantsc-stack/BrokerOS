import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_live_akd_snapshot.dart';

void main() {
  const parser = CrocLiveAkdSnapshotParser();

  test('deduplicates overlapping Matriks rankings and keeps signed net lots', () {
    final snapshot = parser.parse(
      symbol: 'thyao',
      buyerRanking: const [
        CrocLiveAkdNetRow(institution: 'AK', netLots: 532637),
        CrocLiveAkdNetRow(institution: 'GARANTI BBVA', netLots: 525054),
        CrocLiveAkdNetRow(institution: 'ATA', netLots: 1134),
      ],
      sellerRanking: const [
        CrocLiveAkdNetRow(institution: 'IS', netLots: -1057691),
        CrocLiveAkdNetRow(institution: 'ATA', netLots: 1134),
      ],
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.symbol, 'THYAO');
    expect(snapshot.rows, hasLength(4));
    expect(snapshot.positiveNetLots, 1058825);
    expect(snapshot.negativeNetLots, 1057691);
    expect(snapshot.netBookImbalancePercent, closeTo(0.107, 0.001));
    expect(snapshot.isBalanced, isTrue);
  });

  test('rejects conflicting duplicate institution values', () {
    final snapshot = parser.parse(
      symbol: 'THYAO',
      buyerRanking: const [
        CrocLiveAkdNetRow(institution: 'ATA', netLots: 1134),
      ],
      sellerRanking: const [
        CrocLiveAkdNetRow(institution: 'ATA', netLots: 1200),
      ],
    );

    expect(snapshot, isNull);
  });

  test('marks truncated net book as unbalanced', () {
    final snapshot = parser.parse(
      symbol: 'THYAO',
      buyerRanking: const [
        CrocLiveAkdNetRow(institution: 'AK', netLots: 500000),
        CrocLiveAkdNetRow(institution: 'GARANTI', netLots: 400000),
      ],
      sellerRanking: const [
        CrocLiveAkdNetRow(institution: 'IS', netLots: -300000),
      ],
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.isBalanced, isFalse);
    expect(snapshot.netBookImbalancePercent, closeTo(66.666, 0.001));
  });
}
