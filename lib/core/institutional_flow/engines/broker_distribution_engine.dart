import '../models/broker_flow.dart';

class BrokerDistributionEngine {
  const BrokerDistributionEngine();

  List<BrokerFlow> build(String symbol) {
    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    final List<String> names = <String>[
      'İş Yatırım',
      'Yapı Kredi Yatırım',
      'Ak Yatırım',
      'Garanti Yatırım',
      'Merrill Lynch',
    ];

    return List<BrokerFlow>.generate(names.length, (int index) {
      final double direction = ((seed + index * 9) % 3 == 0) ? -1.0 : 1.0;

      final double lot = direction * (900000 + ((seed + index * 31) % 1600000));

      return BrokerFlow(
        brokerName: names[index],
        netLot: lot,
        netValue: lot * (90 + (seed % 160)),
        averagePrice: 90 + (seed % 160) + index * 0.55,
        marketShare: 8.5 + ((seed + index * 7) % 18),
        buyer: lot >= 0,
      );
    });
  }
}
