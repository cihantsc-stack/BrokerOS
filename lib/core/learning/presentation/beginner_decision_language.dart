import '../../decision/models/croc_decision_result.dart';

class BeginnerDecisionLanguage {
  const BeginnerDecisionLanguage._();

  static String simpleTitle(String decision) {
    if (decision.contains('GÜÇLÜ AL')) {
      return 'ÇOK GÜÇLÜ';
    }
    if (decision.contains('SEÇİCİ AL')) {
      return 'OLUMLU';
    }
    if (decision.contains('İZLE')) {
      return 'İZLE';
    }
    if (decision.contains('TEYİT')) {
      return 'BEKLE';
    }
    return 'RİSKLİ';
  }

  static String stars(int score) {
    if (score >= 85) {
      return '★★★★★';
    }
    if (score >= 72) {
      return '★★★★☆';
    }
    if (score >= 58) {
      return '★★★☆☆';
    }
    if (score >= 44) {
      return '★★☆☆☆';
    }
    return '★☆☆☆☆';
  }

  static String plainExplanation(CrocDecisionResult result) {
    final String decision = result.decision;

    if (decision.contains('GÜÇLÜ AL')) {
      return 'Verilerin büyük bölümü olumlu. Yine de tek seferde yüksek miktarla işlem yapma.';
    }
    if (decision.contains('SEÇİCİ AL')) {
      return 'Olumlu sinyaller var. Küçük miktarla veya kademeli işlem daha güvenli.';
    }
    if (decision.contains('İZLE')) {
      return 'Hisse umut veriyor ancak henüz yeterince güçlü değil. Bir süre daha izle.';
    }
    if (decision.contains('TEYİT')) {
      return 'Karar vermek için yeterli güç oluşmadı. Acele etme.';
    }
    return 'Risk göstergeleri yüksek. Şimdilik uzak durmak daha güvenli.';
  }

  static String todayAction(CrocDecisionResult result) {
    final String decision = result.decision;

    if (decision.contains('GÜÇLÜ AL')) {
      return 'Bugün yapılabilecek: İşlem planını kontrol et, stop belirle ve kademeli giriş düşün.';
    }
    if (decision.contains('SEÇİCİ AL')) {
      return 'Bugün yapılabilecek: Küçük miktarla başla veya fiyatın güçlenmesini bekle.';
    }
    if (decision.contains('İZLE')) {
      return 'Bugün yapılabilecek: Favoriye ekle, hemen alım yapma.';
    }
    if (decision.contains('TEYİT')) {
      return 'Bugün yapılabilecek: Bekle ve yeni teyit oluşmasını izle.';
    }
    return 'Bugün yapılabilecek: Yeni işlem açma.';
  }

  static String confidenceText(int confidence) {
    if (confidence >= 85) {
      return 'Çok yüksek';
    }
    if (confidence >= 70) {
      return 'Yüksek';
    }
    if (confidence >= 55) {
      return 'Orta';
    }
    return 'Düşük';
  }

  static String riskText(String risk) {
    final String value = risk.toUpperCase();

    if (value.contains('YÜKSEK')) {
      return 'Yüksek';
    }
    if (value.contains('DÜŞÜK')) {
      return 'Düşük';
    }
    return 'Orta';
  }
}
