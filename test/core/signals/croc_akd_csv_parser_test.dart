import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_akd_csv_parser.dart';

void main() {
  const parser = CrocAkdCsvParser();

  test('parses normalized historical broker rows', () {
    final rows = parser.parse(
      'participant,buy_lots,sell_lots\n'
      'Broker A,100,40\n'
      'Broker B,20,60\n',
    );
    expect(rows, isNotNull);
    expect(rows!.length, 2);
    expect(rows.first.netLots, 60);
    expect(rows.last.netLots, -40);
  });

  test('rejects missing header and malformed numbers', () {
    expect(parser.parse('broker,buy,sell\nA,1,2'), isNull);
    expect(parser.parse('participant,buy_lots,sell_lots\nA,x,2'), isNull);
    expect(parser.parse('participant,buy_lots,sell_lots\nA,-1,2'), isNull);
  });

  test('does not accept an empty report', () {
    expect(parser.parse('participant,buy_lots,sell_lots'), isNull);
  });
}
