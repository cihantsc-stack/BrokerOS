import '../models/broker_consensus.dart';

class CommentEngine {
  const CommentEngine._();

  static String generate(BrokerConsensus consensus) {
    final parts = <String>[];

    if (consensus.smartMoneyScore >= 85) {
      parts.add('Smart Money tarafında güçlü alımlar devam ediyor.');
    } else if (consensus.smartMoneyScore <= 45) {
      parts.add('Kurumsal para çıkışı dikkat çekiyor.');
    } else {
      parts.add('Smart Money görünümü dengeli.');
    }

    if (consensus.technicalScore >= 85) {
      parts.add('Teknik görünüm yukarı yönü destekliyor.');
    } else if (consensus.technicalScore < 55) {
      parts.add('Teknik görünüm henüz güven vermiyor.');
    } else {
      parts.add('Teknik görünüm temkinli pozitif.');
    }

    if (consensus.momentumScore >= 80) {
      parts.add('Momentum alıcıları destekliyor.');
    } else if (consensus.momentumScore < 55) {
      parts.add('Momentum zayıf, acele edilmemeli.');
    }

    if (consensus.newsScore >= 80) {
      parts.add('Haber akışı pozitif tarafta.');
    } else if (consensus.newsScore < 50) {
      parts.add('Haber akışı karar kalitesini zayıflatıyor.');
    }

    if (consensus.riskScore < 60) {
      parts.add('Volatilite nedeniyle risk yükselmiş durumda.');
    }

    if (consensus.gameTheoryScore >= 90) {
      parts.add(
        'Game Theory analizine göre büyük oyuncular pozisyon biriktiriyor olabilir.',
      );
    }

    if (parts.isEmpty) {
      return 'Yeni ve güçlü bir sinyal oluşana kadar temkinli kalınmalı.';
    }

    return parts.join(' ');
  }
}