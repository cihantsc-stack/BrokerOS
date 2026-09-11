import '../models/fund_intelligence_result.dart';
import '../models/fund_metrics_result.dart';

class FundIntelligenceEngine {
  const FundIntelligenceEngine();

  FundIntelligenceResult evaluate(FundMetricsResult metrics) {
    if (!metrics.available) {
      return const FundIntelligenceResult.dataWaiting();
    }

    final strengths = <String>[];
    final risks = <String>[];
    final layers = <String, int>{};

    var performance = 50;
    if ((metrics.return1M ?? 0) > 0) performance += 8;
    if ((metrics.return3M ?? 0) > 0) performance += 10;
    if ((metrics.return6M ?? 0) > 0) performance += 12;
    if ((metrics.return1Y ?? 0) > 0) performance += 15;
    performance = performance.clamp(0, 100);
    layers['performans'] = performance;

    var risk = 70;
    final vol = metrics.annualizedVolatility;
    final dd = metrics.maxDrawdown?.abs();
    if (vol != null) {
      if (vol >= 40) risk -= 30;
      else if (vol >= 20) risk -= 15;
      else strengths.add('Fiyat dalgalanmasi gorece kontrollu.');
    }
    if (dd != null) {
      if (dd >= 30) risk -= 30;
      else if (dd >= 15) risk -= 15;
      else strengths.add('Gecmis maksimum kayip sinirli kalmis.');
    }
    risk = risk.clamp(0, 100);
    layers['risk'] = risk;

    if ((metrics.return3M ?? 0) > 0 && (metrics.return6M ?? 0) > 0) {
      strengths.add('Getiri tek bir kisa doneme dayanmiyor.');
    }
    if ((metrics.return1Y ?? 0) < 0) {
      risks.add('Bir yillik performans negatif.');
    }
    if (metrics.riskLevel == 'YUKSEK') {
      risks.add('Gecmis fiyat serisinde yuksek dalgalanma veya sert dusus var.');
    }

    final score = ((performance * 0.55) + (risk * 0.45)).round().clamp(0, 100);
    final verdict = score >= 75
        ? 'GUCLU ADAY'
        : score >= 60
            ? 'UYGUN ADAY'
            : score >= 45
                ? 'TEMKINLI INCELE'
                : 'ZAYIF GORUNUM';

    final confidence = metrics.observationCount >= 200 ? 'ORTA' : 'DUSUK';
    final unavailable = <String>[
      'KAP fon bildirimleri',
      'portfoy dagilimi',
      'portfoy hisseleri CROC etkisi',
      'makro rejim',
      'fon para akisi',
    ];

    return FundIntelligenceResult(
      available: true,
      score: score,
      verdict: verdict,
      confidence: confidence,
      summary: 'Bu on sonuc yalnizca gercek TEFAS fiyat gecmisi ve risk metriklerinden uretilmistir. Eksik katmanlar skoru olumlu varsayimla sisirmez.',
      strengths: List.unmodifiable(strengths),
      risks: List.unmodifiable(risks),
      layerScores: Map.unmodifiable(layers),
      unavailableLayers: List.unmodifiable(unavailable),
    );
  }
}
