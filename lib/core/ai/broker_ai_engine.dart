import '../models/ai_decision.dart';
import '../models/ai_timeline_step.dart';
import '../models/broker_consensus.dart';
import '../engine/broker_consensus_engine.dart';
import '../models/market_snapshot.dart';

class BrokerAiEngine {
  static AiDecision analyze(MarketSnapshot data) {
    final BrokerConsensus consensus = BrokerConsensusEngine.calculate(data);

    final List<String> comments = [];

    if (consensus.smartMoneyScore >= 85) {
      comments.add('Smart Money tarafında güçlü alımlar devam ediyor.');
    } else if (consensus.smartMoneyScore <= 45) {
      comments.add('Kurumsal para çıkışı dikkat çekiyor.');
    }

    if (consensus.technicalScore >= 85) {
      comments.add('Teknik görünüm yukarı yönü destekliyor.');
    } else {
      comments.add('Teknik görünüm henüz tam güç kazanmadı.');
    }

    if (consensus.newsScore >= 80) {
      comments.add('Haber akışı pozitif tarafta.');
    }

    if (consensus.momentumScore >= 80) {
      comments.add('Momentum alıcıları destekliyor.');
    }

    if (consensus.riskScore < 60) {
      comments.add('Volatilite nedeniyle risk yükselmiş durumda.');
    }

    if (consensus.gameTheoryScore >= 90) {
      comments.add(
        'Game Theory analizine göre büyük oyuncular pozisyon biriktiriyor olabilir.',
      );
    }

    final explanation = comments.join(' ');

    return AiDecision(
      pusuScore: consensus.score,
      decision: consensus.decision,
      confidence: consensus.confidence,
      risk: consensus.riskScore >= 70 ? 'Düşük' : 'Orta',
      explanation: explanation,

      // Bu alanlar AiDecision modelinde zorunlu.
      // Gerçek üretim motoruna bağlanana kadar nötr tutuluyor.
      missions: const <String>[],
      warnings: const <String>[],
      strongestFactor: 'Broker Consensus',
      weakestFactor: 'Belirgin zayıf faktör yok',
      nextTrigger: 'Yeni piyasa verisiyle karar yeniden değerlendirilecek.',
      timeline: const <AiTimelineStep>[],
    );
  }
}
