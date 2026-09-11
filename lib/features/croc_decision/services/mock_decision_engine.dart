import '../models/decision_models.dart';

class MockDecisionEngine {
  const MockDecisionEngine();

  DecisionSnapshot buildSnapshot({String selectedCode = 'ASELS'}) {
    final signals = <DecisionSignal>[
      const DecisionSignal(
        code: 'ASELS',
        company: 'Aselsan Elektronik Sanayi',
        price: 156.75,
        changePercent: 2.79,
        confidence: 91,
        risk: 'Orta',
        horizon: '5–20 işlem günü',
        direction: DecisionDirection.buy,
        buyLow: 154.50,
        buyHigh: 156.20,
        firstTarget: 162.80,
        mainTarget: 168.50,
        stop: 149.80,
        suggestedPortfolioPercent: 8,
        reasons: [
          'Kurumsal para girişi son 60 dakikada hızlandı.',
          'Hacim, 20 günlük ortalamanın belirgin üzerinde.',
          'Orta vadeli trend ve sektör momentumu aynı yönde.',
          'Fincan-kulp kırılımı fiyat ve hacim tarafından doğrulanıyor.',
        ],
        invalidationRules: [
          '149,80 altında günlük kapanışta senaryo geçersiz olur.',
          'Hacim zayıflarken direnç geçilemezse yeni kademe açılmaz.',
          '162,80 üzerinde kalıcılık oluşursa ana hedef devreye girer.',
        ],
      ),
      const DecisionSignal(
        code: 'THYAO',
        company: 'Türk Hava Yolları',
        price: 325.40,
        changePercent: 1.42,
        confidence: 88,
        risk: 'Orta',
        horizon: '5–15 işlem günü',
        direction: DecisionDirection.buy,
        buyLow: 321.00,
        buyHigh: 325.50,
        firstTarget: 336.20,
        mainTarget: 344.80,
        stop: 313.20,
        suggestedPortfolioPercent: 7,
        reasons: [
          'Yabancı payı ve kurumsal işlem dengesi pozitif.',
          'Fiyat kısa vadeli ortalamaların üzerinde.',
          'Hacim teyidi güçleniyor.',
        ],
        invalidationRules: [
          '313,20 altında kapanışta işlem planı iptal edilir.',
          '336,20 direnci hacimsiz test edilirse kâr korunur.',
        ],
      ),
      const DecisionSignal(
        code: 'AKBNK',
        company: 'Akbank',
        price: 68.35,
        changePercent: 0.92,
        confidence: 86,
        risk: 'Düşük-Orta',
        horizon: '10–30 işlem günü',
        direction: DecisionDirection.watch,
        buyLow: 66.80,
        buyHigh: 68.10,
        firstTarget: 71.40,
        mainTarget: 74.20,
        stop: 64.90,
        suggestedPortfolioPercent: 6,
        reasons: [
          'Banka endeksi göreceli güç kazanıyor.',
          'Fon alımları son dönemde pozitif.',
          'Trend olumlu ancak giriş seviyesi henüz ideal değil.',
        ],
        invalidationRules: [
          '64,90 altında görünüm bozulur.',
          '68,10 üzerine hacimli geçiş olmadan acele edilmez.',
        ],
      ),
      const DecisionSignal(
        code: 'KCHOL',
        company: 'Koç Holding',
        price: 184.60,
        changePercent: 1.02,
        confidence: 84,
        risk: 'Orta',
        horizon: '10–30 işlem günü',
        direction: DecisionDirection.watch,
        buyLow: 179.50,
        buyHigh: 182.20,
        firstTarget: 190.40,
        mainTarget: 197.50,
        stop: 173.60,
        suggestedPortfolioPercent: 6,
        reasons: [
          'Holding iskontosu cazip bölgede.',
          'Uzun vadeli trend korunuyor.',
          'Kısa vadede daha iyi maliyet beklenebilir.',
        ],
        invalidationRules: [
          '173,60 altında risk azaltılır.',
          '182,20 üstü teyit olmadan tam pozisyon açılmaz.',
        ],
      ),
      const DecisionSignal(
        code: 'GARAN',
        company: 'Garanti BBVA',
        price: 126.70,
        changePercent: 1.02,
        confidence: 82,
        risk: 'Orta',
        horizon: '5–20 işlem günü',
        direction: DecisionDirection.watch,
        buyLow: 123.80,
        buyHigh: 125.40,
        firstTarget: 131.40,
        mainTarget: 136.20,
        stop: 120.40,
        suggestedPortfolioPercent: 5,
        reasons: [
          'Kurumsal işlem dengesi pozitif.',
          'Sektör momentumu destekliyor.',
          'Mevcut fiyat, tercih edilen alım bandının üzerinde.',
        ],
        invalidationRules: [
          '120,40 altında işlem planı iptal edilir.',
          '125,40 altına geri çekilme izlenir.',
        ],
      ),
    ];

    final selected = signals.firstWhere(
      (item) => item.code == selectedCode,
      orElse: () => signals.first,
    );

    const factors = <AnalysisFactor>[
      AnalysisFactor(
        title: 'Piyasa Rejimi',
        detail:
            'Seçici alım modu; geniş piyasa yerine güçlü hisseler öne çıkıyor.',
        score: 78,
        state: FactorState.positive,
      ),
      AnalysisFactor(
        title: 'Teknik Yapı',
        detail: 'Trend, EMA yapısı ve kırılım sinyalleri pozitif.',
        score: 89,
        state: FactorState.positive,
      ),
      AnalysisFactor(
        title: 'Hacim',
        detail: 'Hacim artışı hareketi destekliyor.',
        score: 86,
        state: FactorState.positive,
      ),
      AnalysisFactor(
        title: 'Kurumsal Para',
        detail: 'Net kurumsal giriş güçlü fakat gün içi hız değişebilir.',
        score: 84,
        state: FactorState.positive,
      ),
      AnalysisFactor(
        title: 'Fon Hareketleri',
        detail: 'Hisse yoğun fonlarda alım eğilimi pozitif.',
        score: 76,
        state: FactorState.positive,
      ),
      AnalysisFactor(
        title: 'Haber Etkisi',
        detail:
            'Pozitif haber akışı fiyatlanıyor; yeni haber teyidi beklenmeli.',
        score: 72,
        state: FactorState.neutral,
      ),
      AnalysisFactor(
        title: 'Risk / Getiri',
        detail: 'Planlanan seviyelerde yaklaşık 1:2,4 risk-getiri dengesi.',
        score: 81,
        state: FactorState.positive,
      ),
    ];

    return DecisionSnapshot(
      marketMode: 'SEÇİCİ ALIM MODU',
      marketSummary:
          'Piyasanın tamamına değil; kurumsal para, hacim ve teknik yapı tarafından aynı anda doğrulanan hisselere odaklan.',
      marketConfidence: 87,
      opportunities: signals,
      selected: selected,
      factors: factors,
    );
  }
}
