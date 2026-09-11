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

    var result = intelligence.score.toDouble();

    final volatility = metrics.annualizedVolatility;
    final drawdown = metrics.maxDrawdown?.abs();

    if (risk == 'DUSUK') {
      if (volatility != null && volatility < 15) result += 12;
      if (drawdown != null && drawdown < 10) result += 10;
      if (metrics.riskLevel == 'YUKSEK') result -= 25;
    } else if (risk == 'ORTA') {
      if (metrics.riskLevel == 'ORTA') result += 10;
      if (metrics.riskLevel == 'YUKSEK') result -= 10;
    } else if (risk == 'YUKSEK') {
      if ((metrics.return6M ?? 0) > 0) result += 8;
      if ((metrics.return1Y ?? 0) > 0) result += 8;
    }

    if (horizon == '0-3 AY') {
      if ((metrics.return1M ?? 0) > 0) result += 8;
      if ((metrics.return3M ?? 0) > 0) result += 10;
      if (drawdown != null && drawdown >= 15) result -= 18;
    } else if (horizon == '3-12 AY') {
      if ((metrics.return3M ?? 0) > 0) result += 8;
      if ((metrics.return6M ?? 0) > 0) result += 10;
    } else {
      if ((metrics.return6M ?? 0) > 0) result += 8;
      if ((metrics.return1Y ?? 0) > 0) result += 12;
    }

    if (goal == 'PARAYI KORU') {
      if (metrics.riskLevel == 'DUSUK') result += 14;
      if (drawdown != null && drawdown >= 10) result -= 12;
    } else if (goal == 'DENGELI BUYUME') {
      if ((metrics.return6M ?? 0) > 0) result += 8;
      if (metrics.riskLevel == 'ORTA') result += 8;
    } else if (goal == 'BUYUME') {
      if ((metrics.return6M ?? 0) > 0) result += 10;
      if ((metrics.return1Y ?? 0) > 0) result += 12;
    }

    return result.round().clamp(0, 100);
  }

  String label(int score) {
    if (score >= 85) return 'COK UYUMLU';
    if (score >= 72) return 'UYUMLU';
    if (score >= 60) return 'DEGERLENDIR';
    return 'TEMKINLI';
  }

  List<String> reasons({
    required FundMetricsResult metrics,
    required String horizon,
    required String risk,
    required String goal,
  }) {
    final result = <String>[];

    if (horizon == '0-3 AY' && (metrics.return3M ?? 0) > 0) {
      result.add('Kisa vadeli performans pozitif.');
    }
    if (horizon == '3-12 AY' && (metrics.return6M ?? 0) > 0) {
      result.add('Orta vadeli performans pozitif.');
    }
    if (horizon == '1 YIL+' && (metrics.return1Y ?? 0) > 0) {
      result.add('Bir yillik performans pozitif.');
    }
    if (risk == 'DUSUK' && metrics.riskLevel == 'DUSUK') {
      result.add('Gecmis dalgalanma tercihinle uyumlu.');
    }
    if (risk == 'ORTA' && metrics.riskLevel != 'YUKSEK') {
      result.add('Risk seviyesi orta profile yakin.');
    }
    if (goal == 'BUYUME' && (metrics.return6M ?? 0) > 0) {
      result.add('Buyume hedefi icin 6 aylik trend destekliyor.');
    }
    if (goal == 'PARAYI KORU' && (metrics.maxDrawdown?.abs() ?? 999) < 10) {
      result.add('Gecmis maksimum dusus sinirli.');
    }

    if (result.isEmpty) {
      result.add('Gercek TEFAS verileriyle profil uyumu sinirli.');
    }

    return List.unmodifiable(result.take(3));
  }
}
