import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_akd_engine.dart';
import 'package:mobile/core/akd/croc_akd_models.dart';
import 'package:mobile/core/akd/croc_matriks_akd_parser.dart';

void main() {
  const parser=CrocMatriksAkdParser();
  const engine=CrocAkdEngine();

  test('preserves zero sell and negative cost from Matriks exports',(){
    final rows=parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['KTLEV TEST',173934,9.61,0,0,173934,7.475907,173934,9.61],
      ['PASEU TEST',2482455,25.90652,2289004,28.37796,4771459,8.95651,193451,-3.33677],
    ]);
    expect(rows,hasLength(2));
    expect(rows.first.dataFlags,contains(CrocAkdDataFlag.zeroSell));
    expect(rows.last.cost,-3.33677);
    expect(rows.last.dataFlags,contains(CrocAkdDataFlag.negativeCost));
  });

  test('THYAO sample orders real top five buyers and sellers',(){
    final rows=parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['YAPI KREDI',7701159,288.696,5358781,288.693,13059940,18.935,2342378,288.704],
      ['HSBC',629290,287.529,70674,284.471,699964,1.015,558616,287.915],
      ['IS',3093560,286.981,2724640,287.619,5818200,8.436,368920,282.273],
      ['QNB YATIRIM',1427353,287.049,1145909,287.882,2573262,3.731,281444,283.658],
      ['VAKIF',901291,286.425,665824,287.551,1567115,2.272,235467,283.243],
      ['DENIZ',991777,289.2,3192392,289.8,4184169,6.0,-2200615,289.796],
      ['YATIRIM FINANSMAN',447666,286.0,1713059,286.0,2160725,3.0,-1265393,285.763],
      ['BANK OF AMERICA',6556236,283.0,7240306,283.0,13786542,19.99,-684070,283.202],
      ['ZIRAAT',719832,286.0,937390,286.0,1657222,2.0,-217558,286.481],
      ['AK',2465287,283.0,2638981,283.0,5094268,7.39,-173694,283.195],
    ]);
    final result=engine.analyze(rows);
    expect(result.topBuyers.map((r)=>r.institution),['YAPI KREDI','HSBC','IS','QNB YATIRIM','VAKIF']);
    expect(result.topSellers.map((r)=>r.institution),['DENIZ','YATIRIM FINANSMAN','BANK OF AMERICA','ZIRAAT','AK']);
    expect(result.buyerConcentrationPercent,closeTo(100,0.001));
    expect(result.sellerConcentrationPercent,closeTo(100,0.001));
  });

  test('KTLEV-like one-sided market is marked distorted, not strong AKD', () {
    final rows = parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['QNB YATIRIM',173934,9.61,0,0,173934,30,173934,9.61],
      ['GARANTI',163159,9.61,0,0,163159,28,163159,9.61],
      ['MIDAS',136507,9.61,0,0,136507,24,136507,9.61],
      ['IS',95312,9.61,35281,9.61,130593,18,60031,9.61],
    ]);
    final result = engine.analyze(rows);
    expect(rows.first.dataFlags, contains(CrocAkdDataFlag.oneSidedFlow));
    expect(result.oneSidedTurnoverPercent, greaterThan(60));
    expect(result.isFlowDistorted, isTrue);
    expect(result.signal, CrocAkdConcentrationSignal.distorted);
  });

  test('normal two-sided THYAO-style flow is not marked distorted', () {
    final rows = parser.parseRows([
      ['Araci Kurum','Alis','Ortalama','Satis','Ortalama','Toplam','Yuzde','Net','Maliyet'],
      ['YAPI KREDI',7701159,288.696,5358781,288.693,13059940,18.935,2342378,288.704],
      ['DENIZ',991777,289.2,3192392,289.8,4184169,6,-2200615,289.796],
    ]);
    final result = engine.analyze(rows);
    expect(result.oneSidedTurnoverPercent, 0);
    expect(result.isFlowDistorted, isFalse);
    expect(result.signal, CrocAkdConcentrationSignal.balanced);
  });

  test('rejects invalid distortion threshold', () {
    expect(
      () => const CrocAkdEngine(distortionTurnoverThresholdPercent: 101)
          .analyze(const []),
      throwsArgumentError,
    );
  });

  test('rejects invalid topCount',(){
    expect(()=>const CrocAkdEngine(topCount:0).analyze(const []),throwsArgumentError);
  });
}
