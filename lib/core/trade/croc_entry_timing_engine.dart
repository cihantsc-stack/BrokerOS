import '../analysis/croc_technical_analysis.dart';
import '../master_engine/croc_master_stock_engine.dart';

class CrocEntryTimingResult {
  final String decision;
  final int score;
  final String message;
  final List<String> reasons;

  const CrocEntryTimingResult({
    required this.decision,
    required this.score,
    required this.message,
    required this.reasons,
  });

  bool get canEnterNow =>
      decision == 'ŞİMDİ GİRİLEBİLİR' || decision == 'UYGUN GİRİŞ';

  bool get shouldWait =>
      decision == 'GERİ ÇEKİLME BEKLE' || decision == 'TEYİT BEKLE';

  bool get trainMissed => decision == 'TREN KAÇMIŞ';
}

class CrocEntryTimingEngine {
  const CrocEntryTimingEngine._();

  static CrocEntryTimingResult evaluate({
    required double lastPrice,
    required CrocTechnicalAnalysis technical,
    required CrocMasterStockResult master,
  }) {
    if (lastPrice <= 0) {
      return const CrocEntryTimingResult(
        decision: 'VERİ BEKLENİYOR',
        score: 0,
        message: 'Giriş zamanlaması için fiyat verisi bekleniyor.',
        reasons: <String>[],
      );
    }

    final masterDecision = master.masterDecision;

    // Master AL demiyorsa Entry Engine yeni AL üretmez.
    if (masterDecision != 'AL' && masterDecision != 'GÜÇLÜ AL') {
      return CrocEntryTimingResult(
        decision: masterDecision == 'UZAK DUR' ? 'UZAK DUR' : 'TEYİT BEKLE',
        score: master.masterScore.clamp(0, 100),
        message: masterDecision == 'UZAK DUR'
            ? 'Ana CROC kararı yeni giriş için uygun değil.'
            : 'Ana CROC kararı henüz yeni giriş için yeterli değil.',
        reasons: <String>['Master karar: $masterDecision.'],
      );
    }

    var score = 70.0;
    final reasons = <String>[];

    final atrPercent = technical.atr <= 0
        ? 0.0
        : (technical.atr / lastPrice) * 100;

    final distanceFromSupport = technical.support <= 0
        ? 999.0
        : ((lastPrice - technical.support) / lastPrice) * 100;

    final distanceToResistance = technical.resistance <= 0
        ? 999.0
        : ((technical.resistance - lastPrice) / lastPrice) * 100;

    final stopDistance = technical.stop <= 0
        ? 999.0
        : ((lastPrice - technical.stop) / lastPrice) * 100;

    // ---------------------------------------------------------
    // TREND
    // ---------------------------------------------------------

    if (technical.trend == 'Yükseliş') {
      score += 10;
      reasons.add('Ana trend yükseliş yönünde.');
    } else if (technical.trend == 'Düşüş') {
      score -= 25;
      reasons.add('Ana trend düşüş yönünde.');
    } else {
      score -= 5;
      reasons.add('Trend henüz net değil.');
    }

    // ---------------------------------------------------------
    // RSI / KOVALAMA RİSKİ
    // ---------------------------------------------------------

    if (technical.rsi > 82) {
      score -= 35;
      reasons.add('RSI aşırı ısınmış; fiyat kovalanmamalı.');
    } else if (technical.rsi > 76) {
      score -= 22;
      reasons.add('RSI yüksek; geri çekilme riski arttı.');
    } else if (technical.rsi > 70) {
      score -= 10;
      reasons.add('RSI güçlü fakat giriş bölgesi pahalılaşmaya başladı.');
    } else if (technical.rsi >= 50 && technical.rsi <= 68) {
      score += 8;
      reasons.add('RSI giriş için sağlıklı momentum bölgesinde.');
    }

    // ---------------------------------------------------------
    // DESTEK KONUMU
    // ---------------------------------------------------------

    if (distanceFromSupport >= 0 && distanceFromSupport <= 3.0) {
      score += 12;
      reasons.add('Fiyat yakın teknik desteğe yakın.');
    } else if (distanceFromSupport <= 6.0) {
      score += 5;
      reasons.add('Fiyat destek bölgesinden fazla uzaklaşmamış.');
    } else if (distanceFromSupport > 10.0 && distanceFromSupport < 999.0) {
      score -= 15;
      reasons.add('Fiyat yakın destekten belirgin şekilde uzaklaşmış.');
    }

    // ---------------------------------------------------------
    // DİRENÇ KONUMU
    // ---------------------------------------------------------

    if (distanceToResistance >= 0 && distanceToResistance <= 1.5) {
      score -= 18;
      reasons.add('Fiyat yakın direncin hemen altında.');
    } else if (distanceToResistance > 1.5 && distanceToResistance <= 4.0) {
      score -= 7;
      reasons.add('Yakın direnç nedeniyle giriş alanı dar.');
    } else if (distanceToResistance > 4.0 && distanceToResistance < 999.0) {
      score += 5;
      reasons.add('İlk dirence kadar hareket alanı mevcut.');
    }

    // ---------------------------------------------------------
    // HACİM
    // ---------------------------------------------------------

    if (technical.volumeRatio >= 1.20 && technical.volumeRatio <= 2.50) {
      score += 8;
      reasons.add('Hacim hareketi destekliyor.');
    } else if (technical.volumeRatio > 3.50) {
      score -= 8;
      reasons.add('Hacim aşırı sıçramış; geç giriş riski var.');
    } else if (technical.volumeRatio < 0.70) {
      score -= 8;
      reasons.add('Hacim teyidi zayıf.');
    }

    // ---------------------------------------------------------
    // RİSK / GETİRİ
    // ---------------------------------------------------------

    if (technical.riskReward >= 1.8) {
      score += 10;
      reasons.add('Risk/getiri oranı giriş için güçlü.');
    } else if (technical.riskReward >= 1.3) {
      score += 4;
      reasons.add('Risk/getiri oranı kabul edilebilir.');
    } else if (technical.riskReward < 1.0) {
      score -= 25;
      reasons.add('Risk/getiri oranı yeni giriş için zayıf.');
    }

    // ---------------------------------------------------------
    // STOP MESAFESİ
    // ---------------------------------------------------------

    if (stopDistance <= 3.5) {
      score += 5;
      reasons.add('Stop mesafesi kontrollü.');
    } else if (stopDistance > 6.5 && stopDistance < 999.0) {
      score -= 12;
      reasons.add('Stop mesafesi yeni giriş için geniş.');
    }

    // ---------------------------------------------------------
    // MASTER KALİTESİ
    // ---------------------------------------------------------

    if (master.masterScore >= 85) {
      score += 8;
    } else if (master.masterScore >= 75) {
      score += 4;
    }

    if (master.riskScore >= 70) {
      score -= 20;
      reasons.add('Master risk seviyesi yüksek.');
    }

    score = score.clamp(0, 100);

    // ---------------------------------------------------------
    // TREN KAÇMIŞ KONTROLÜ
    // ---------------------------------------------------------

    final overheated =
        technical.rsi > 76 &&
        distanceFromSupport > 7.0 &&
        technical.volumeRatio > 1.50;

    if (overheated) {
      return CrocEntryTimingResult(
        decision: 'TREN KAÇMIŞ',
        score: score.round(),
        message:
            'Hisse güçlü olabilir fakat mevcut fiyat yeni giriş için fazla uzamış.',
        reasons: List<String>.unmodifiable(reasons),
      );
    }

    // ---------------------------------------------------------
    // SON ZAMANLAMA KARARI
    // ---------------------------------------------------------

    String decision;
    String message;

    if (score >= 82) {
      decision = 'ŞİMDİ GİRİLEBİLİR';
      message = 'CROC kararı ve mevcut fiyat konumu yeni giriş için uyumlu.';
    } else if (score >= 68) {
      decision = 'UYGUN GİRİŞ';
      message = 'Giriş yapılabilir; stop ve pozisyon büyüklüğü korunmalı.';
    } else if (score >= 50) {
      decision = 'GERİ ÇEKİLME BEKLE';
      message =
          'Hisse olumlu ancak mevcut fiyat yerine daha iyi giriş beklenmeli.';
    } else {
      decision = 'TEYİT BEKLE';
      message =
          'Ana fikir olumlu olsa bile mevcut fiyat yeni giriş için yeterli değil.';
    }

    return CrocEntryTimingResult(
      decision: decision,
      score: score.round(),
      message: message,
      reasons: List<String>.unmodifiable(reasons),
    );
  }
}
