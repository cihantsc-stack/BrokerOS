import '../models/ai_decision.dart';
import '../models/ai_timeline_step.dart';
import '../models/stock_analysis.dart';

class StockDecisionEngine {
  const StockDecisionEngine._();

  static AiDecision analyze(StockAnalysis stock) {
    final factors = <String, int>{
      'Teknik Analiz': stock.technicalScore,
      'Smart Money': stock.smartMoneyScore,
      'Kurumsal Hareket': stock.institutionalScore,
      'Haber Akışı': stock.newsScore,
      'Risk Kalitesi': stock.riskScore,
      'Momentum': stock.momentumScore,
    };

    final strongest = factors.entries.reduce(
      (current, next) => current.value >= next.value ? current : next,
    );

    final weakest = factors.entries.reduce(
      (current, next) => current.value <= next.value ? current : next,
    );

    return AiDecision(
      pusuScore: stock.brokerConsensus,
      decision: stock.decision,
      explanation: _buildExplanation(stock, strongest.key),
      confidence: stock.confidence.clamp(0, 100),
      risk: stock.risk,
      missions: _buildMissions(stock),
      warnings: _buildWarnings(stock),
      strongestFactor: strongest.key,
      weakestFactor: weakest.key,
      nextTrigger: _buildNextTrigger(stock),
      timeline: _buildTimeline(stock),
    );
  }

  static String _buildExplanation(StockAnalysis stock, String strongestFactor) {
    final direction = stock.decision.contains('AL')
        ? 'pozitif'
        : stock.decision.contains('SAT')
        ? 'negatif'
        : 'temkinli';

    return '${stock.symbol} için birleşik görünüm $direction. '
        'En güçlü katkı $strongestFactor tarafından geliyor. '
        'Broker Consensus ${stock.brokerConsensus}/100 seviyesinde. '
        'Risk ${stock.risk.toLowerCase()} olduğu için işlem planı stop '
        'disipliniyle uygulanmalı. Yatırım tavsiyesi değildir (YTD).';
  }

  static List<String> _buildMissions(StockAnalysis stock) {
    final missions = <String>[
      'Açılışın ilk 15 dakikasında fiyat ve hacim teyidi bekle.',
      '${stock.stop.toStringAsFixed(2)} stop seviyesine sadık kal.',
    ];

    if (stock.smartMoneyScore >= 80) {
      missions.add('Kurumsal para girişinin devam edip etmediğini izle.');
    }

    if (stock.momentumScore >= 80) {
      missions.add('Momentum korunursa işlemi kademeli yönet.');
    } else {
      missions.add('Momentum güçlenmeden pozisyon büyütme.');
    }

    return List<String>.unmodifiable(missions);
  }

  static List<String> _buildWarnings(StockAnalysis stock) {
    final warnings = <String>[];

    if (stock.riskScore < 70) {
      warnings.add('Risk kalitesi zayıf; stopsuz işlem yapma.');
    }

    if (stock.newsScore < 60) {
      warnings.add('Haber akışı zayıf; ani hareketlere karşı temkinli ol.');
    }

    if (stock.smartMoneyScore < 65) {
      warnings.add('Smart Money desteği sınırlı; fiyatı yukarıdan kovalama.');
    }

    if (warnings.isEmpty) {
      warnings.add('Ana risk, işlem planının dışına çıkılmasıdır.');
    }

    return List<String>.unmodifiable(warnings);
  }

  static String _buildNextTrigger(StockAnalysis stock) {
    return '${stock.target1.toStringAsFixed(2)} üzerindeki kapanışta '
        '${stock.target2.toStringAsFixed(2)} hedefi izlenir. '
        '${stock.stop.toStringAsFixed(2)} altında günlük kapanışta '
        'karar yeniden hesaplanır.';
  }

  static List<AiTimelineStep> _buildTimeline(StockAnalysis stock) {
    final steps = <AiTimelineStep>[
      const AiTimelineStep(
        time: '09:30',
        title: 'Açılışı izle',
        description:
            'İlk hareketlerde işlem yapmadan fiyat ve hacim dengesini gözlemle.',
      ),
      const AiTimelineStep(
        time: '09:45',
        title: 'İlk teyit',
        description:
            'Smart Money ve teknik görünümün aynı yönde olup olmadığını kontrol et.',
      ),
    ];

    if (stock.smartMoneyScore >= 80 && stock.technicalScore >= 75) {
      steps.add(
        const AiTimelineStep(
          time: '10:00',
          title: 'Kademeli giriş',
          description:
              'Kurumsal para desteği sürüyorsa küçük pozisyonla planı başlat.',
          isCritical: true,
        ),
      );
    } else {
      steps.add(
        const AiTimelineStep(
          time: '10:00',
          title: 'Bekle',
          description:
              'Yeterli teyit oluşmadı. Yeni sinyal gelmeden pozisyon açma.',
          isCritical: true,
        ),
      );
    }

    if (stock.momentumScore >= 80) {
      steps.add(
        const AiTimelineStep(
          time: '12:00',
          title: 'Momentum kontrolü',
          description:
              'Momentum korunuyorsa mevcut planı sürdür. Zayıflama varsa riski azalt.',
        ),
      );
    }

    steps.add(
      const AiTimelineStep(
        time: '15:30',
        title: 'Gün sonu değerlendirmesi',
        description:
            'Kararı, riski ve Smart Money yönünü kapanış öncesinde yeniden değerlendir.',
      ),
    );

    return List<AiTimelineStep>.unmodifiable(steps);
  }
}
