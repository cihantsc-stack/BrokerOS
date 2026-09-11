enum BrokerMarketMode { gucluAl, seciciAl, bekle, riskAzalt, gucluRiskAzalt }

enum BrokerRiskLevel { dusuk, orta, yuksek }

class BrokerAiDecision {
  final BrokerMarketMode mode;
  final BrokerRiskLevel risk;
  final int confidence;
  final int score;
  final List<String> positiveReasons;
  final List<String> riskReasons;
  final DateTime timestamp;

  const BrokerAiDecision({
    required this.mode,
    required this.risk,
    required this.confidence,
    required this.score,
    required this.positiveReasons,
    required this.riskReasons,
    required this.timestamp,
  });

  String get modeLabel {
    switch (mode) {
      case BrokerMarketMode.gucluAl:
        return 'GÜÇLÜ AL';
      case BrokerMarketMode.seciciAl:
        return 'SEÇİCİ AL';
      case BrokerMarketMode.bekle:
        return 'BEKLE';
      case BrokerMarketMode.riskAzalt:
        return 'RİSK AZALT';
      case BrokerMarketMode.gucluRiskAzalt:
        return 'GÜÇLÜ RİSK AZALT';
    }
  }

  String get riskLabel {
    switch (risk) {
      case BrokerRiskLevel.dusuk:
        return 'DÜŞÜK';
      case BrokerRiskLevel.orta:
        return 'ORTA';
      case BrokerRiskLevel.yuksek:
        return 'YÜKSEK';
    }
  }

  String get summary {
    switch (mode) {
      case BrokerMarketMode.gucluAl:
        return 'Piyasa geneli güçlü. Kontrollü biçimde fırsatlar değerlendirilebilir.';
      case BrokerMarketMode.seciciAl:
        return 'Piyasa tamamen risksiz değil. Güçlü hisselerde seçici hareket edilmeli.';
      case BrokerMarketMode.bekle:
        return 'Sinyaller karışık. Yeni işlem için daha net teyit beklenmeli.';
      case BrokerMarketMode.riskAzalt:
        return 'Risk göstergeleri yükseliyor. Pozisyon boyutları azaltılmalı.';
      case BrokerMarketMode.gucluRiskAzalt:
        return 'Piyasa baskısı yüksek. Sermaye koruma öncelikli olmalı.';
    }
  }
}
