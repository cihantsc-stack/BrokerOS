import '../models/broker_consensus.dart';

class MissionEngine {
  const MissionEngine._();

  static List<String> build(BrokerConsensus consensus) {
    final missions = <String>[];

    if (consensus.smartMoneyScore >= 80) {
      missions.add(
        'Kurumsal para girişini ilk 30 dakika boyunca takip et.',
      );
    }

    if (consensus.momentumScore >= 75) {
      missions.add(
        'Momentum güçlü. İşlemleri kademeli artır.',
      );
    } else {
      missions.add(
        'Momentum zayıf. Büyük pozisyon açma.',
      );
    }

    if (consensus.riskScore < 60) {
      missions.add(
        'Stop-loss seviyesine kesinlikle sadık kal.',
      );
    }

    if (consensus.newsScore >= 80) {
      missions.add(
        'Gün içindeki haber akışını yakından izle.',
      );
    }

    if (missions.isEmpty) {
      missions.add(
        'Yeni sinyal oluşana kadar sabırlı ol.',
      );
    }

    return missions;
  }
}