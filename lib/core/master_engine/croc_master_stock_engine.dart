import '../ai/council/broker_council_engine.dart';
import '../ai/council/council_result.dart';
import '../analysis/croc_technical_analysis.dart';
import '../models/stock_analysis.dart';

class CrocMasterStockResult {
  final StockAnalysis stock;
  final CouncilResult council;

  final int masterScore;
  final String masterDecision;
  final int masterConfidence;

  final int technicalScore;
  final int momentumScore;
  final int riskScore;

  final int smartMoneyScore;
  final int institutionalScore;
  final int newsScore;
  final int dataQualityScore;

  final List<String> masterReasons;

  const CrocMasterStockResult({
    required this.stock,
    required this.council,
    required this.masterScore,
    required this.masterDecision,
    required this.masterConfidence,
    required this.technicalScore,
    required this.momentumScore,
    required this.riskScore,
    required this.smartMoneyScore,
    required this.institutionalScore,
    required this.newsScore,
    required this.dataQualityScore,
    required this.masterReasons,
  });

  bool get hasSmartMoneyData => smartMoneyScore > 0;
  bool get hasInstitutionalData => institutionalScore > 0;
  bool get hasNewsData => newsScore > 0;

  int get activeEngineCount => stock.activeSignalCount;
}

class CrocMasterStockEngine {
  const CrocMasterStockEngine._();

  static CrocMasterStockResult evaluate({
    required String symbol,
    required String company,
    required double lastPrice,
    required CrocTechnicalAnalysis technical,

    double? dailyChange,
    double? volume,

    // Gercek veri yoksa 0 birak.
    int smartMoneyScore = 0,
    int institutionalScore = 0,
    int newsScore = 0,
    int dataQualityScore = 100,

    double? smartMoneyFlow,
    String? firstInstitution,
    String? secondInstitution,
    String? thirdInstitution,
  }) {
    final technicalScore = technical.score.clamp(0, 100);

    final momentumScore = _calculateMomentumScore(technical);

    // StockAnalysis standardi:
    // 0 = veri yok
    // 100 = cok yuksek risk
    final riskScore = _calculateRiskScore(
      technical: technical,
      lastPrice: lastPrice,
    );

    final normalizedSmartMoney = smartMoneyScore.clamp(0, 100);
    final normalizedInstitutional = institutionalScore.clamp(0, 100);
    final normalizedNews = newsScore.clamp(0, 100);
    final normalizedDataQuality = dataQualityScore.clamp(0, 100);

    final initialStock = StockAnalysis(
      symbol: symbol.toUpperCase(),
      company: company,
      aiScore: technicalScore,
      decision: technical.decision,
      entry: lastPrice,
      target1: technical.target,
      target2: technical.target2,
      stop: technical.stop,
      confidence: 0,
      risk: technical.risk,
      reasons: List<String>.from(technical.reasons),
      lastPrice: lastPrice,
      dailyChange: dailyChange,
      volume: volume,
      firstInstitution: firstInstitution,
      secondInstitution: secondInstitution,
      thirdInstitution: thirdInstitution,
      smartMoneyFlow: smartMoneyFlow,
      technicalScore: technicalScore,
      smartMoneyScore: normalizedSmartMoney,
      institutionalScore: normalizedInstitutional,
      newsScore: normalizedNews,
      riskScore: riskScore,
      momentumScore: momentumScore,
    );

    final council = BrokerCouncilEngine.evaluate(initialStock);

    final rawMasterScore = _calculateMasterScore(
      stock: initialStock,
      council: council,
    );

    final dataScorePenalty = normalizedDataQuality >= 95
        ? 0
        : normalizedDataQuality >= 80
        ? 4
        : normalizedDataQuality >= 60
        ? 10
        : 18;

    final masterScore = (rawMasterScore - dataScorePenalty).clamp(0, 100);

    final masterDecision = _finalDecision(
      councilDecision: council.finalDecision,
      masterScore: masterScore,
      technical: technical,
      riskScore: riskScore,
    );

    final rawMasterConfidence = _calculateConfidence(
      stock: initialStock,
      council: council,
      masterScore: masterScore,
    );

    final dataConfidencePenalty = normalizedDataQuality >= 95
        ? 0
        : normalizedDataQuality >= 80
        ? 8
        : normalizedDataQuality >= 60
        ? 18
        : 30;

    final masterConfidence = (rawMasterConfidence - dataConfidencePenalty)
        .clamp(0, 96);

    final reasons = _buildReasons(
      technical: technical,
      council: council,
      technicalScore: technicalScore,
      momentumScore: momentumScore,
      riskScore: riskScore,
      smartMoneyScore: normalizedSmartMoney,
      institutionalScore: normalizedInstitutional,
      newsScore: normalizedNews,
    );

    final finalStock = StockAnalysis(
      symbol: initialStock.symbol,
      company: initialStock.company,
      aiScore: masterScore,
      decision: masterDecision,
      entry: initialStock.entry,
      target1: initialStock.target1,
      target2: initialStock.target2,
      stop: initialStock.stop,
      confidence: masterConfidence,
      risk: initialStock.risk,
      reasons: reasons,
      lastPrice: initialStock.lastPrice,
      dailyChange: initialStock.dailyChange,
      volume: initialStock.volume,
      firstInstitution: initialStock.firstInstitution,
      secondInstitution: initialStock.secondInstitution,
      thirdInstitution: initialStock.thirdInstitution,
      smartMoneyFlow: initialStock.smartMoneyFlow,
      technicalScore: initialStock.technicalScore,
      smartMoneyScore: initialStock.smartMoneyScore,
      institutionalScore: initialStock.institutionalScore,
      newsScore: initialStock.newsScore,
      riskScore: initialStock.riskScore,
      momentumScore: initialStock.momentumScore,
    );

    return CrocMasterStockResult(
      stock: finalStock,
      council: council,
      masterScore: masterScore,
      masterDecision: masterDecision,
      masterConfidence: masterConfidence,
      technicalScore: technicalScore,
      momentumScore: momentumScore,
      riskScore: riskScore,
      smartMoneyScore: normalizedSmartMoney,
      institutionalScore: normalizedInstitutional,
      newsScore: normalizedNews,
      dataQualityScore: normalizedDataQuality,
      masterReasons: reasons,
    );
  }

  static int _calculateMomentumScore(CrocTechnicalAnalysis technical) {
    var score = 50.0;

    // RSI
    if (technical.rsi >= 52 && technical.rsi <= 68) {
      score += 18;
    } else if (technical.rsi >= 45 && technical.rsi < 52) {
      score += 6;
    } else if (technical.rsi > 68 && technical.rsi <= 75) {
      score += 8;
    } else if (technical.rsi > 75) {
      score -= 8;
    } else if (technical.rsi < 35) {
      score -= 15;
    }

    // MACD
    if (technical.macd > technical.macdSignal && technical.macdHistogram > 0) {
      score += 20;
    } else if (technical.macd < technical.macdSignal &&
        technical.macdHistogram < 0) {
      score -= 20;
    }

    // Trend
    if (technical.trend == 'Yükseliş') {
      score += 14;
    } else if (technical.trend == 'Düşüş') {
      score -= 14;
    }

    // Hacim
    if (technical.volumeRatio >= 1.50) {
      score += 12;
    } else if (technical.volumeRatio >= 1.20) {
      score += 8;
    } else if (technical.volumeRatio < 0.70) {
      score -= 8;
    }

    return score.round().clamp(1, 100);
  }

  static int _calculateRiskScore({
    required CrocTechnicalAnalysis technical,
    required double lastPrice,
  }) {
    if (lastPrice <= 0) {
      return 0;
    }

    var risk = 20.0;

    final stopDistance = ((lastPrice - technical.stop).abs() / lastPrice) * 100;

    final atrRatio = technical.atr <= 0
        ? 0.0
        : (technical.atr / lastPrice) * 100;

    // Stop mesafesi.
    if (stopDistance > 8) {
      risk += 35;
    } else if (stopDistance > 6) {
      risk += 26;
    } else if (stopDistance > 4) {
      risk += 17;
    } else if (stopDistance > 2.5) {
      risk += 9;
    } else {
      risk += 4;
    }

    // Volatilite.
    if (atrRatio >= 5) {
      risk += 25;
    } else if (atrRatio >= 4) {
      risk += 18;
    } else if (atrRatio >= 2.5) {
      risk += 10;
    } else {
      risk += 4;
    }

    // Risk/getiri.
    if (technical.riskReward < 1.0) {
      risk += 20;
    } else if (technical.riskReward < 1.30) {
      risk += 12;
    } else if (technical.riskReward >= 2.0) {
      risk -= 8;
    }

    // Asiri alim riski.
    if (technical.rsi > 80) {
      risk += 15;
    } else if (technical.rsi > 75) {
      risk += 10;
    }

    // Negatif trend.
    if (technical.trend == 'Düşüş') {
      risk += 12;
    }

    return risk.round().clamp(1, 100);
  }

  static int _calculateMasterScore({
    required StockAnalysis stock,
    required CouncilResult council,
  }) {
    // CROC MASTER DECISION ENGINE V2
    // Tek skor katmani: Council skoru tekrar puanlamaz.
    // 0 = veri yok; eksik motorun agirligi kalan aktif motorlara dagitilir.
    final values = <String, int>{
      'technical': stock.technicalScore,
      'momentum': stock.momentumScore,
      'smartMoney': stock.smartMoneyScore,
      'institutional': stock.institutionalScore,
      'news': stock.newsScore,
    };

    final weights = <String, double>{
      'technical': 0.34,
      'momentum': 0.24,
      'smartMoney': 0.17,
      'institutional': 0.15,
      'news': 0.10,
    };

    // Gercek KAP verisi varsa haber etkisi gecici olarak daha anlamli hale gelir.
    if (stock.newsScore > 0) {
      weights['technical'] = 0.30;
      weights['momentum'] = 0.20;
      weights['news'] = 0.18;
    }

    var weighted = 0.0;
    var activeWeight = 0.0;

    for (final entry in values.entries) {
      if (entry.value <= 0) continue;
      final weight = weights[entry.key] ?? 0.0;
      weighted += entry.value.clamp(0, 100) * weight;
      activeWeight += weight;
    }

    if (activeWeight <= 0) return 0;

    var score = (weighted / activeWeight).round();

    // Risk yon oyu degil, firsat kalitesi filtresidir.
    if (stock.riskScore >= 85) {
      score -= 18;
    } else if (stock.riskScore >= 70) {
      score -= 10;
    } else if (stock.riskScore >= 55) {
      score -= 5;
    } else if (stock.riskScore > 0 && stock.riskScore <= 30) {
      score += 2;
    }

    // Council burada bilerek skora katilmaz; sadece confidence katmaninda kullanilir.
    if (council.confidence < 0) return 0;

    return score.clamp(0, 100);
  }

  static int _calculateConfidence({
    required StockAnalysis stock,
    required CouncilResult council,
    required int masterScore,
  }) {
    if (stock.activeSignalCount <= 0) return 0;

    final active = <int>[
      if (stock.technicalScore > 0) stock.technicalScore,
      if (stock.momentumScore > 0) stock.momentumScore,
      if (stock.smartMoneyScore > 0) stock.smartMoneyScore,
      if (stock.institutionalScore > 0) stock.institutionalScore,
      if (stock.newsScore > 0) stock.newsScore,
    ];

    if (active.isEmpty) return 0;

    final mean = active.reduce((a, b) => a + b) / active.length;
    final spread =
        active.map((v) => (v - mean).abs()).reduce((a, b) => a + b) /
        active.length;

    // Coverage ve bagimsiz motorlarin birbirine uyumu confidence'i belirler.
    final coverage = (active.length / 5.0).clamp(0.0, 1.0);
    final agreement = (100.0 - spread * 1.35).clamp(25.0, 100.0);

    var confidence = 38.0 + (coverage * 32.0) + (agreement * 0.22);

    // Council yalnizca teyit kalitesi olarak confidence'a sinirli etki eder.
    if (council.confidence > 0) {
      confidence =
          (confidence * 0.82) + (council.confidence.clamp(0, 100) * 0.18);
    }

    if (stock.riskScore >= 70) confidence -= 7;
    if (masterScore < 40) confidence = confidence.clamp(0, 80);

    return confidence.round().clamp(0, 96);
  }

  static String _finalDecision({
    required String councilDecision,
    required int masterScore,
    required CrocTechnicalAnalysis technical,
    required int riskScore,
  }) {
    // V2: karar yonunu Master Score belirler. Council sadece confidence teyididir.
    var decision = _decisionFromScore(masterScore);
    final councilWasWaiting = councilDecision == 'VERİ BEKLENİYOR';
    // Degisken sadece eski Council durumunu kaybetmeden izlenebilir tutar.
    if (councilWasWaiting && masterScore <= 0) {
      decision = 'VERİ BEKLENİYOR';
    }

    // Master skor guvenlik katmani.
    if (masterScore < 35) {
      decision = 'UZAK DUR';
    } else if (masterScore < 50) {
      // V2: dusuk/orta firsat skoru yeni alim icin BEKLE'dir.
      // RISK AZALT etiketi yalniz gercek yuksek risk katmaninda kullanilir.
      decision = 'BEKLE';
    }

    // Yuksek risk yeni alim kararini bloke eder.
    if (riskScore >= 70 && (decision == 'AL' || decision == 'GÜÇLÜ AL')) {
      decision = 'BEKLE';
    } else if (riskScore >= 55 && decision == 'GÜÇLÜ AL') {
      decision = 'AL';
    }

    // RSI asiri isinmissa kovalamiyoruz.
    if (technical.rsi > 78 && (decision == 'AL' || decision == 'GÜÇLÜ AL')) {
      decision = 'BEKLE';
    }

    // Zayif risk/getiri ile yeni alim yok.
    if (technical.riskReward < 1.0 &&
        (decision == 'AL' || decision == 'GÜÇLÜ AL')) {
      decision = 'BEKLE';
    }

    return decision;
  }

  static String _decisionFromScore(int score) {
    if (score >= 85) return 'GÜÇLÜ AL';
    if (score >= 70) return 'AL';
    if (score >= 50) return 'BEKLE';
    if (score >= 35) return 'RİSK AZALT';
    return 'UZAK DUR';
  }

  static List<String> _buildReasons({
    required CrocTechnicalAnalysis technical,
    required CouncilResult council,
    required int technicalScore,
    required int momentumScore,
    required int riskScore,
    required int smartMoneyScore,
    required int institutionalScore,
    required int newsScore,
  }) {
    final reasons = <String>[];

    reasons.add(
      'Teknik AI $technicalScore/100, Momentum AI $momentumScore/100.',
    );

    reasons.add(
      'Risk seviyesi $riskScore/100 '
      '(yüksek skor = yüksek risk).',
    );

    if (smartMoneyScore > 0) {
      reasons.add('Smart Money AI $smartMoneyScore/100.');
    } else {
      reasons.add('Smart Money verisi henüz bağlı değil; karara katılmadı.');
    }

    if (institutionalScore > 0) {
      reasons.add('Kurumsal akış skoru $institutionalScore/100.');
    } else {
      reasons.add('Kurumsal akış verisi henüz bağlı değil; karara katılmadı.');
    }

    if (newsScore > 0) {
      reasons.add('Haber / KAP skoru $newsScore/100.');
    } else {
      reasons.add('Haber / KAP skoru henüz bağlı değil; karara katılmadı.');
    }

    if (council.votes.isNotEmpty) {
      reasons.add(
        'Broker Council: ${council.finalDecision} '
        '• güven %${council.confidence}.',
      );

      reasons.add(council.conflictSummary);
    }

    // Teknik motorun en anlamli ilk 3 gerekcesini koru.
    for (final reason in technical.reasons.take(3)) {
      reasons.add(reason);
    }

    return List<String>.unmodifiable(reasons);
  }
}
