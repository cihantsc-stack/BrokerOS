import '../models/ai_timeline_step.dart';
import '../models/broker_consensus.dart';

class TimelineEngine {
  const TimelineEngine._();

  static List<AiTimelineStep> build(
    BrokerConsensus consensus,
  ) {
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

    if (consensus.smartMoneyScore >= 80 &&
        consensus.technicalScore >= 75) {
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

    if (consensus.momentumScore >= 80) {
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