import '../../kap_intelligence/fund_kap_intelligence_service.dart';
import '../models/fund_intelligence_result.dart';
import '../models/fund_metrics_result.dart';

class FundIntelligenceEngine {
  const FundIntelligenceEngine();

  FundIntelligenceResult evaluate(
    FundMetricsResult metrics, {
    FundKapIntelligenceResult kap = FundKapIntelligenceResult.empty,
  }) {
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
      if (vol >= 40) {
        risk -= 30;
      } else if (vol >= 20) {
        risk -= 15;
      } else {
        strengths.add('Fiyat dalgalanması görece kontrollü.');
      }
    }
    if (dd != null) {
      if (dd >= 30) {
        risk -= 30;
      } else if (dd >= 15) {
        risk -= 15;
      } else {
        strengths.add('Geçmiş maksimum kayıp sınırlı kalmış.');
      }
    }
    risk = risk.clamp(0, 100);
    layers['risk'] = risk;

    if ((metrics.return3M ?? 0) > 0 && (metrics.return6M ?? 0) > 0) {
      strengths.add('Getiri tek bir kısa döneme dayanmıyor.');
    }
    if ((metrics.return1Y ?? 0) < 0) {
      risks.add('Bir yıllık performans negatif.');
    }
    if (metrics.riskLevel == 'YUKSEK') {
      risks.add('Geçmiş fiyat serisinde yüksek dalgalanma veya sert düşüş var.');
    }

    var score = ((performance * 0.55) + (risk * 0.45)).round().clamp(0, 100);

    if (kap.hasData) {
      layers['kap'] = kap.score;
      score = ((performance * 0.45) + (risk * 0.35) + (kap.score * 0.20))
          .round()
          .clamp(0, 100);

      final sentiment = kap.sentiment.toUpperCase();
      if (sentiment.contains('OLUMLU') || kap.score >= 65) {
        strengths.add('Son gerçek fon KAP bildirimi CROC değerlendirmesini destekliyor.');
      }
      if (sentiment.contains('OLUMSUZ') || kap.score <= 35) {
        risks.add('Son gerçek fon KAP bildirimi ek risk işareti taşıyor.');
      }
    }

    final verdict = score >= 75
        ? 'GÜÇLÜ ADAY'
        : score >= 60
            ? 'UYGUN ADAY'
            : score >= 45
                ? 'TEMKİNLİ İNCELE'
                : 'ZAYIF GÖRÜNÜM';

    final confidence = kap.hasData && metrics.observationCount >= 200
        ? 'YÜKSEK'
        : metrics.observationCount >= 200
            ? 'ORTA'
            : 'DÜŞÜK';

    final unavailable = <String>[
      if (!kap.hasData) 'KAP fon bildirimleri',
      'portföy dağılımı',
      'portföy hisseleri CROC etkisi',
      'makro rejim',
      'fon para akışı',
    ];

    return FundIntelligenceResult(
      available: true,
      score: score,
      verdict: verdict,
      confidence: confidence,
      summary: kap.hasData
          ? 'Gerçek TEFAS fiyat/risk verileri ve erişilebilen gerçek fon KAP bildirimi birlikte değerlendirildi. Eksik katmanlar skoru şişirmez.'
          : 'Sonuç gerçek TEFAS fiyat geçmişi ve risk metriklerinden üretildi. Fon KAP verisi bulunamazsa olumlu varsayım yapılmaz.',
      strengths: List.unmodifiable(strengths),
      risks: List.unmodifiable(risks),
      layerScores: Map.unmodifiable(layers),
      unavailableLayers: List.unmodifiable(unavailable),
    );
  }
}
