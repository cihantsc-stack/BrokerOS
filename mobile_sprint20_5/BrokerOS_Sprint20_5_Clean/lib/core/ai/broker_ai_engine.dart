import '../engine/broker_consensus_engine.dart';
import '../models/ai_decision.dart';
import '../models/ai_timeline_step.dart';
import '../models/broker_consensus.dart';
import '../models/market_snapshot.dart';

import 'comment_engine.dart';
import 'confidence_engine.dart';
import 'decision_engine.dart';
import 'mission_engine.dart';
import 'timeline_engine.dart';

class BrokerAiEngine {
  const BrokerAiEngine._();

  static AiDecision analyze(
    MarketSnapshot snapshot,
  ) {
    final BrokerConsensus consensus =
        BrokerConsensusEngine.calculate(snapshot);

    final String decision =
        DecisionEngine.build(consensus);

    final int confidence =
        ConfidenceEngine.calculate(consensus);

    final String explanation =
        CommentEngine.generate(consensus);

    final List<String> missions =
        MissionEngine.build(consensus);

    final List<AiTimelineStep> timeline =
        TimelineEngine.build(consensus);

    final List<String> warnings =
        _buildWarnings(consensus);

    return AiDecision(
      pusuScore: consensus.score,
      decision: decision,
      explanation: explanation,
      confidence: confidence,
      risk: _risk(consensus),
      missions: missions,
      warnings: warnings,
      strongestFactor: _strongest(consensus),
      weakestFactor: _weakest(consensus),
      nextTrigger: _nextTrigger(consensus),

      // Sprint23
      timeline: timeline,
    );
  }

  static String _risk(
    BrokerConsensus c,
  ) {
    if (c.riskScore >= 80) {
      return 'Düşük';
    }

    if (c.riskScore >= 60) {
      return 'Orta';
    }

    return 'Yüksek';
  }

  static String _strongest(
    BrokerConsensus c,
  ) {
    final map = {
      'Teknik Analiz': c.technicalScore,
      'Smart Money': c.smartMoneyScore,
      'Momentum': c.momentumScore,
      'Haber Akışı': c.newsScore,
      'Game Theory': c.gameTheoryScore,
      'Risk Kalitesi': c.riskScore,
    };

    return map.entries
        .reduce(
          (a, b) => a.value >= b.value ? a : b,
        )
        .key;
  }

  static String _weakest(
    BrokerConsensus c,
  ) {
    final map = {
      'Teknik Analiz': c.technicalScore,
      'Smart Money': c.smartMoneyScore,
      'Momentum': c.momentumScore,
      'Haber Akışı': c.newsScore,
      'Game Theory': c.gameTheoryScore,
      'Risk Kalitesi': c.riskScore,
    };

    return map.entries
        .reduce(
          (a, b) => a.value <= b.value ? a : b,
        )
        .key;
  }

  static String _nextTrigger(
    BrokerConsensus c,
  ) {
    if (c.score >= 90) {
      return 'Smart Money gücü korunursa agresif alım devam eder.';
    }

    if (c.score >= 80) {
      return 'Teknik görünüm biraz daha güçlenirse AL sinyali güçlenecek.';
    }

    if (c.score >= 65) {
      return 'Momentum yükselirse karar AL tarafına dönebilir.';
    }

    return 'Risk düşmeden yeni pozisyon önerilmiyor.';
  }

  static List<String> _buildWarnings(
    BrokerConsensus c,
  ) {
    final warnings = <String>[];

    if (c.riskScore < 60) {
      warnings.add(
        'Stopsuz işlem yapma.',
      );
    }

    if (c.smartMoneyScore < 60) {
      warnings.add(
        'Kurumsal para desteği zayıf.',
      );
    }

    if (c.newsScore < 50) {
      warnings.add(
        'Haber akışı olumsuz.',
      );
    }

    if (warnings.isEmpty) {
      warnings.add(
        'Plan dışına çıkma.',
      );
    }

    return warnings;
  }
}