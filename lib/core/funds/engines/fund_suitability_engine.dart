import '../models/fund_intelligence_result.dart';
import '../models/fund_metrics_result.dart';

class FundSuitabilityEngine {
  const FundSuitabilityEngine();

  int score({
    required FundMetricsResult metrics,
    required FundIntelligenceResult intelligence,
    required String horizon,
    required String risk,
    required String goal,
  }) {
    if (!metrics.available || !intelligence.available) return 0;

    final riskFit = _riskFit(metrics, risk);
    final horizonFit = _horizonFit(metrics, horizon);
    final goalFit = _goalFit(metrics, goal);

    final profileFit =
        (riskFit * 0.35) + (horizonFit * 0.35) + (goalFit * 0.30);

    var result =
        (intelligence.score * 0.55) + (profileFit * 0.45);

    // Eksik veri katmanları skoru olumlu varsayımla şişirmesin.
    // KAP/portföy/makro/akış katmanları tamamlandıkça tavan doğal olarak yükselir.
    final missing = intelligence.unavailableLayers.length;
    final ceiling = missing >= 4
        ? 92
        : missing >= 2
            ? 96
            : 100;

    result = result.clamp(0, ceiling.toDouble());
    return result.round();
  }

  String label(int score) {
    if (score >= 85) return 'YÜKSEK UYUM';
    if (score >= 75) return 'İYİ UYUM';
    if (score >= 65) return 'ORTA UYUM';
    return 'TEMKİNLİ';
  }

  List<String> reasons({
    required FundMetricsResult metrics,
    required String horizon,
    required String risk,
    required String goal,
  }) {
    final result = <String>[];

    if (horizon == '0-3 AY' && (metrics.return3M ?? 0) > 0) {
      result.add('Kısa vadeli performans pozitif.');
    }
    if (horizon == '3-12 AY' && (metrics.return6M ?? 0) > 0) {
      result.add('Orta vadeli performans pozitif.');
    }
    if (horizon == '1 YIL+' && (metrics.return1Y ?? 0) > 0) {
      result.add('Bir yıllık performans pozitif.');
    }
    if (risk == 'DUSUK' && metrics.riskLevel == 'DUSUK') {
      result.add('Geçmiş dalgalanma tercihinle uyumlu.');
    }
    if (risk == 'ORTA' && metrics.riskLevel != 'YUKSEK') {
      result.add('Risk seviyesi orta profile yakın.');
    }
    if (goal == 'BUYUME' && (metrics.return6M ?? 0) > 0) {
      result.add('Büyüme hedefi için 6 aylık trend destekliyor.');
    }
    if (goal == 'PARAYI KORU' && (metrics.maxDrawdown?.abs() ?? 999) < 10) {
      result.add('Geçmiş maksimum düşüş sınırlı.');
    }

    if (result.isEmpty) {
      result.add('Gerçek TEFAS verileriyle profil uyumu sınırlı.');
    }

    return List.unmodifiable(result.take(3));
  }

  double _riskFit(FundMetricsResult metrics, String preference) {
    final level = metrics.riskLevel.toUpperCase();

    if (preference == 'DUSUK') {
      if (level == 'DUSUK') return 100;
      if (level == 'ORTA') return 62;
      return 28;
    }

    if (preference == 'ORTA') {
      if (level == 'ORTA') return 100;
      if (level == 'DUSUK') return 82;
      return 55;
    }

    if (level == 'YUKSEK') return 92;
    if (level == 'ORTA') return 84;
    return 68;
  }

  double _horizonFit(FundMetricsResult metrics, String horizon) {
    if (horizon == '0-3 AY') {
      final one = _returnComponent(metrics.return1M, scale: 2.8);
      final three = _returnComponent(metrics.return3M, scale: 1.6);
      return (one * 0.45) + (three * 0.55);
    }

    if (horizon == '3-12 AY') {
      final three = _returnComponent(metrics.return3M, scale: 1.4);
      final six = _returnComponent(metrics.return6M, scale: 0.9);
      return (three * 0.40) + (six * 0.60);
    }

    final six = _returnComponent(metrics.return6M, scale: 0.8);
    final year = _returnComponent(metrics.return1Y, scale: 0.5);
    return (six * 0.35) + (year * 0.65);
  }

  double _goalFit(FundMetricsResult metrics, String goal) {
    final volatility = metrics.annualizedVolatility;
    final drawdown = metrics.maxDrawdown?.abs();

    if (goal == 'PARAYI KORU') {
      var score = 72.0;
      if (metrics.riskLevel == 'DUSUK') score += 18;
      if (metrics.riskLevel == 'YUKSEK') score -= 28;
      if (drawdown != null) score += drawdown < 10 ? 10 : drawdown >= 20 ? -18 : 0;
      if (volatility != null) score += volatility < 15 ? 8 : volatility >= 30 ? -12 : 0;
      return score.clamp(0, 100);
    }

    if (goal == 'DENGELI BUYUME') {
      final growth = _returnComponent(metrics.return6M, scale: 0.9);
      final balance = metrics.riskLevel == 'ORTA'
          ? 100.0
          : metrics.riskLevel == 'DUSUK'
              ? 84.0
              : 58.0;
      return (growth * 0.55) + (balance * 0.45);
    }

    final six = _returnComponent(metrics.return6M, scale: 0.9);
    final year = _returnComponent(metrics.return1Y, scale: 0.55);
    return (six * 0.45) + (year * 0.55);
  }

  double _returnComponent(double? value, {required double scale}) {
    if (value == null) return 45;
    return (50 + (value * scale)).clamp(0, 100);
  }
}
