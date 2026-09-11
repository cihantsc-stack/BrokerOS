import '../models/absorption_result.dart';
import '../models/flow_context_input.dart';

class AbsorptionEngine {
  const AbsorptionEngine();

  AbsorptionResult evaluate(FlowContextInput input) {
    if (!input.institutionalDataAvailable || input.brokers.isEmpty) {
      return const AbsorptionResult.dataWaiting();
    }

    final buyers = input.brokers.where((item) => item.netLot > 0).toList();
    final sellers = input.brokers.where((item) => item.netLot < 0).toList();

    if (buyers.isEmpty || sellers.isEmpty) {
      return const AbsorptionResult(
        state: AbsorptionState.low,
        score: 10,
        coverageRatio: 0,
        status: 'ABSORPSIYON TEYIDI YOK',
        reasons: <String>['Karsi yonlu anlamli kurum akisi bulunmuyor.'],
      );
    }

    final totalBuyLot = buyers.fold<double>(
      0,
      (sum, item) => sum + item.netLot.abs(),
    );

    final totalSellLot = sellers.fold<double>(
      0,
      (sum, item) => sum + item.netLot.abs(),
    );

    if (totalSellLot <= 0) {
      return const AbsorptionResult.dataWaiting(
        status: 'SATIS AKISI HESAPLANAMADI',
      );
    }

    final coverageRatio = (totalBuyLot / totalSellLot).clamp(0.0, 2.0);
    var score = (coverageRatio * 70).round();

    final priceChange = input.priceChangePercent;
    final volumeRatio = input.volumeRatio;

    if (priceChange != null && priceChange < -2) {
      score += 8;
    }

    if (volumeRatio != null && volumeRatio >= 1.5) {
      score += 8;
    }

    score = score.clamp(0, 100);

    final AbsorptionState state;
    if (score >= 75) {
      state = AbsorptionState.high;
    } else if (score >= 50) {
      state = AbsorptionState.medium;
    } else {
      state = AbsorptionState.low;
    }

    final reasons = <String>[
      'Alim lotu / satis lotu karsilama orani: ${coverageRatio.toStringAsFixed(2)}x.',
      if (priceChange != null)
        'Fiyat degisimi: %${priceChange.toStringAsFixed(2)}.',
      if (volumeRatio != null)
        'Hacim orani: ${volumeRatio.toStringAsFixed(2)}x.',
    ];

    return AbsorptionResult(
      state: state,
      score: score,
      coverageRatio: coverageRatio,
      status: state == AbsorptionState.high
          ? 'SATIS ABSORBE EDILIYOR OLABILIR'
          : state == AbsorptionState.medium
          ? 'KISMI ABSORPSIYON IHTIMALI'
          : 'ABSORPSIYON ZAYIF',
      reasons: List<String>.unmodifiable(reasons),
    );
  }
}
