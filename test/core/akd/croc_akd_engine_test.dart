import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_akd_engine.dart';

void main() {
  test('ranks net buyers and sellers and calculates top concentration', () {
    const engine = CrocAkdEngine(topCount: 2, balanceBand: 0.01);
    final result = engine.evaluate(const [
      CrocAkdBrokerRow(institution: 'YAPI KREDI', buyLots: 7, sellLots: 5, totalLots: 12, netLots: 2),
      CrocAkdBrokerRow(institution: 'HSBC', buyLots: 3, sellLots: 2, totalLots: 5, netLots: 1),
      CrocAkdBrokerRow(institution: 'DENIZ', buyLots: 1, sellLots: 3, totalLots: 4, netLots: -2),
      CrocAkdBrokerRow(institution: 'YATIRIM FINANSMAN', buyLots: 1, sellLots: 2.5, totalLots: 3.5, netLots: -1.5),
      CrocAkdBrokerRow(institution: 'MIDAS', buyLots: 2, sellLots: 1.5, totalLots: 3.5, netLots: .5),
      CrocAkdBrokerRow(institution: 'OTHER', buyLots: 1, sellLots: 1, totalLots: 2, netLots: 0),
    ]);

    expect(result.buyers.map((row) => row.institution), ['YAPI KREDI', 'HSBC']);
    expect(result.sellers.map((row) => row.institution), ['DENIZ', 'YATIRIM FINANSMAN']);
    expect(result.positiveNetLots, 3.5);
    expect(result.negativeNetLots, 3.5);
    expect(result.topBuyerConcentration, closeTo(3 / 3.5, 1e-9));
    expect(result.topSellerConcentration, 1);
    expect(result.balance, CrocAkdBalance.sellerConcentrated);
  });

  test('ignores malformed rows instead of contaminating AKD metrics', () {
    const engine = CrocAkdEngine();
    final result = engine.evaluate(const [
      CrocAkdBrokerRow(institution: '', buyLots: 1, sellLots: 0, totalLots: 1, netLots: 1),
      CrocAkdBrokerRow(institution: 'VALID', buyLots: 2, sellLots: 1, totalLots: 3, netLots: 1),
    ]);
    expect(result.buyers.single.institution, 'VALID');
    expect(result.positiveNetLots, 1);
  });
}
