import '../models/analysis_result.dart';

class AnalysisService {
  static AnalysisResult getAselsReport() {
    return const AnalysisResult(
      symbol: 'ASELS',
      name: 'ASELSAN',
      assetType: 'Hisse',
      decision: 'AL',
      aiScore: 94,
      confidence: 92,
      risk: 'Orta',
      entry: 148.20,
      stop: 145.40,
      targets: [154.80, 160.20, 166.00],
      whyBuy: [
        'Smart Money alımda',
        'Savunma sektörü güçlü',
        'MACD AL sinyali üretti',
        'RSI yükseliş teyidinde',
        'Kurumsal para girişi var',
      ],
      whyNotBuy: [
        'Direnç bölgesine yakın',
        'Volatilite artabilir',
        'Makro veri riski var',
      ],
      changeMyMind: '145.40 altında günlük kapanış olursa karar BEKLE seviyesine iner.',
      brokerDna: {
        'Teknik': 94,
        'Kurumsal': 96,
        'Para Akışı': 92,
        'Haber': 88,
        'Risk': 82,
        'Momentum': 95,
      },
      gameTheory:
          'Geçmiş benzer senaryolarda kurumsal alım devam ettiğinde 3-7 gün içinde yukarı hareket olasılığı artmıştır.',
      finalComment:
          'ASELS bugün seçici alım için güçlü aday. Ancak stop seviyesine sadık kalınmalı.',
    );
  }
}