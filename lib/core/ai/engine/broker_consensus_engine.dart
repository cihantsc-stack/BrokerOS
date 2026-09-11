import '../models/broker_ai_decision.dart';
import '../models/broker_ai_input.dart';

class BrokerConsensusEngine {
  const BrokerConsensusEngine();

  BrokerAiDecision analyze(BrokerAiInput input) {
    int score = 50;
    int usedSignals = 0;

    final List<String> positiveReasons = <String>[];
    final List<String> riskReasons = <String>[];

    void applySignal({
      required double value,
      required double positiveThreshold,
      required double negativeThreshold,
      required int weight,
      required String positiveText,
      required String negativeText,
    }) {
      usedSignals++;

      if (value >= positiveThreshold) {
        score += weight;
        positiveReasons.add(positiveText);
      } else if (value <= negativeThreshold) {
        score -= weight;
        riskReasons.add(negativeText);
      }
    }

    if (input.bist100Change != null) {
      applySignal(
        value: input.bist100Change!,
        positiveThreshold: 0.40,
        negativeThreshold: -0.40,
        weight: 12,
        positiveText: 'BIST 100 pozitif bölgede',
        negativeText: 'BIST 100 satış baskısı altında',
      );
    }

    if (input.bist30Change != null) {
      applySignal(
        value: input.bist30Change!,
        positiveThreshold: 0.35,
        negativeThreshold: -0.35,
        weight: 10,
        positiveText: 'BIST 30 ana hisseleri piyasayı destekliyor',
        negativeText: 'BIST 30 ana hisselerinde zayıflık var',
      );
    }

    if (input.viop30Change != null) {
      applySignal(
        value: input.viop30Change!,
        positiveThreshold: 0.30,
        negativeThreshold: -0.30,
        weight: 10,
        positiveText: 'VİOP 30 risk iştahını destekliyor',
        negativeText: 'VİOP 30 temkinli görünüme işaret ediyor',
      );
    }

    applySignal(
      value: input.usdTryChange,
      positiveThreshold: -0.35,
      negativeThreshold: 0.70,
      weight: 7,
      positiveText: 'Dolar/TL hareketi sakin',
      negativeText: 'Dolar/TL yükselişi piyasa riskini artırıyor',
    );

    applySignal(
      value: input.eurTryChange,
      positiveThreshold: -0.35,
      negativeThreshold: 0.70,
      weight: 5,
      positiveText: 'Euro/TL tarafında baskı sınırlı',
      negativeText: 'Euro/TL yükselişi maliyet baskısına işaret ediyor',
    );

    applySignal(
      value: input.gramGoldChange,
      positiveThreshold: -0.30,
      negativeThreshold: 0.90,
      weight: 6,
      positiveText: 'Güvenli liman talebi dengeli',
      negativeText: 'Altındaki sert yükseliş riskten kaçışı gösteriyor',
    );

    if (input.stockChanges.isNotEmpty) {
      usedSignals++;

      final int positiveCount = input.stockChanges
          .where((double value) => value > 0)
          .length;
      final double breadth = positiveCount / input.stockChanges.length;

      if (breadth >= 0.67) {
        score += 15;
        positiveReasons.add('İzlenen hisselerin çoğu pozitif');
      } else if (breadth <= 0.33) {
        score -= 15;
        riskReasons.add('İzlenen hisselerin çoğu negatif');
      }
    }

    score = score.clamp(0, 100);

    final BrokerMarketMode mode;
    if (score >= 78) {
      mode = BrokerMarketMode.gucluAl;
    } else if (score >= 61) {
      mode = BrokerMarketMode.seciciAl;
    } else if (score >= 43) {
      mode = BrokerMarketMode.bekle;
    } else if (score >= 25) {
      mode = BrokerMarketMode.riskAzalt;
    } else {
      mode = BrokerMarketMode.gucluRiskAzalt;
    }

    final BrokerRiskLevel risk;
    if (score >= 70) {
      risk = BrokerRiskLevel.dusuk;
    } else if (score >= 42) {
      risk = BrokerRiskLevel.orta;
    } else {
      risk = BrokerRiskLevel.yuksek;
    }

    final int confidence = (55 + usedSignals * 5 + (score - 50).abs() ~/ 3)
        .clamp(55, 94);

    if (positiveReasons.isEmpty) {
      positiveReasons.add('Belirgin güçlü pozitif teyit oluşmadı');
    }

    if (riskReasons.isEmpty) {
      riskReasons.add('Şu an belirgin olağan dışı risk sinyali yok');
    }

    return BrokerAiDecision(
      mode: mode,
      risk: risk,
      confidence: confidence,
      score: score,
      positiveReasons: positiveReasons.take(3).toList(),
      riskReasons: riskReasons.take(3).toList(),
      timestamp: input.timestamp,
    );
  }
}
