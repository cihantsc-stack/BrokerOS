import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_akd_decision_bridge.dart';
import 'package:mobile/core/akd/croc_akd_engine.dart';
import 'package:mobile/core/akd/croc_matriks_akd_parser.dart';

void main() {
  const parser = CrocMatriksAkdParser();
  const engine = CrocAkdEngine();
  const bridge = CrocAkdDecisionBridge();

  test('KTLEV limit-lock style sample can never confirm buyer direction', () {
    final rows = parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['QNB YATIRIM',173934,9.61,0,0,173934,30,173934,9.61],
      ['GARANTI',163159,9.61,0,0,163159,28,163159,9.61],
      ['MIDAS',136507,9.61,0,0,136507,24,136507,9.61],
      ['IS',0,0,473600,9.61,473600,18,-473600,9.61],
    ]);

    final result = engine.analyze(rows);
    final evidence = bridge.inspect(result);

    expect(result.isBalancedNetBook, isTrue);
    expect(result.isFlowDistorted, isTrue);
    expect(evidence.isEligible, isFalse);
    expect(evidence.bias, CrocAkdDecisionBias.unavailable);
  });

  test('THYAO two-sided complete sample stays eligible and neutral', () {
    final rows = parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['YAPI KREDI',7701159,288.696,5358781,288.693,13059940,18.935,2342378,288.704],
      ['DENIZ',991777,289.2,3334155,289.8,4325932,6,-2342378,289.796],
    ]);

    final result = engine.analyze(rows);
    final evidence = bridge.inspect(result);

    expect(result.isBalancedNetBook, isTrue);
    expect(result.isFlowDistorted, isFalse);
    expect(evidence.isEligible, isTrue);
    expect(evidence.bias, CrocAkdDecisionBias.neutral);
  });

  test('truncated real-style export cannot become directional evidence', () {
    final rows = parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['YAPI KREDI',7701159,288.696,5358781,288.693,13059940,18.935,2342378,288.704],
      ['HSBC',629290,287.529,70674,284.471,699964,1.015,558616,287.915],
      ['IS',3093560,286.981,2724640,287.619,5818200,8.436,368920,282.273],
    ]);

    final result = engine.analyze(rows);
    final evidence = bridge.inspect(result);

    expect(result.isBalancedNetBook, isFalse);
    expect(evidence.isEligible, isFalse);
    expect(evidence.bias, CrocAkdDecisionBias.unavailable);
  });
}
