import '../../desktop_dashboard/models/daily_trade_candidate.dart';
import '../../desktop_dashboard/services/daily_trade_scanner_service.dart';
import '../../desktop_dashboard/services/market_master_decision_service.dart';
import '../models/decision_models.dart';

class LiveDecisionEngine {
  LiveDecisionEngine();

  Future<DecisionSnapshot> buildSnapshot({
    String selectedCode = 'ASELS',
    List<String>? opportunityCodes,
  }) async {
    final allCandidates = await DailyTradeScannerService.instance.scan();

    if (allCandidates.isEmpty) {
      throw Exception(
        'Karar Merkezi icin CROC taramasinda uygun BIST adayi bulunamadi.',
      );
    }

    var ranked = allCandidates;

    if (opportunityCodes != null && opportunityCodes.isNotEmpty) {
      final allowed = opportunityCodes
          .map((e) => e.toUpperCase().trim())
          .where((e) => e.isNotEmpty)
          .toSet();

      ranked = allCandidates
          .where((candidate) => allowed.contains(candidate.symbol))
          .toList();

      if (ranked.isEmpty) {
        ranked = allCandidates;
      }
    }

    final topFive = ranked.take(5).toList();
    final signals = topFive.map(_signalFromCandidate).toList();

    final wantedCode = selectedCode.toUpperCase().trim();
    final selectedCandidate = topFive.firstWhere(
      (candidate) => candidate.symbol == wantedCode,
      orElse: () => topFive.first,
    );
    final selected = _signalFromCandidate(selectedCandidate);

    final scanner = DailyTradeScannerService.instance;
    final master = const MarketMasterDecisionService().evaluate(
      candidates: allCandidates,
      sectors: scanner.latestSectorStrengths,
      globalScore: scanner.latestGlobalScore,
    );

    final avgConfidence =
        (topFive.fold<int>(0, (sum, candidate) => sum + candidate.crocScore) /
                topFive.length)
            .round()
            .clamp(0, 100);

    return DecisionSnapshot(
      marketMode: master.mode,
      marketSummary:
          'Karar Merkezi, CROC BIST 100 taramasinin en guclu 5 adayini '
          'otomatik siralar. Sabit veya manuel hisse listesi kullanilmaz.',
      marketConfidence: avgConfidence,
      opportunities: signals,
      selected: selected,
      factors: _factorsFor(selectedCandidate),
    );
  }

  DecisionSignal _signalFromCandidate(DailyTradeCandidate candidate) {
    final rawDirection = _directionFor(candidate.crocScore);

    final firstTargetUpside = candidate.livePrice <= 0
        ? 0.0
        : ((candidate.resistance - candidate.livePrice) / candidate.livePrice) *
              100;

    final direction =
        firstTargetUpside < 1.0 &&
            (rawDirection == DecisionDirection.strongBuy ||
                rawDirection == DecisionDirection.buy)
        ? DecisionDirection.watch
        : rawDirection;

    return DecisionSignal(
      code: candidate.symbol,
      company: candidate.company,
      price: candidate.livePrice,
      changePercent: candidate.changePercent,
      confidence: candidate.crocScore,
      risk: candidate.risk,
      horizon: 'Gunluk trade adayi',
      direction: direction,
      buyLow: candidate.entryLow,
      buyHigh: candidate.entryHigh,
      firstTarget: candidate.resistance,
      mainTarget: candidate.target,
      stop: candidate.stop,
      suggestedPortfolioPercent: _portfolioPercent(candidate),
      reasons: [
        candidate.tradeReason,
        candidate.contextLabel,
        'Teknik skor ${candidate.technicalScore}/100',
        'Risk/Getiri 1:${candidate.riskReward.toStringAsFixed(1)}',
      ],
      invalidationRules: [
        '${candidate.stop.toStringAsFixed(2)} altinda senaryo yeniden degerlendirilir.',
        'CROC tarama kosullari bozulursa aday siralamasi degisebilir.',
      ],
    );
  }

  DecisionDirection _directionFor(int score) {
    if (score >= 85) return DecisionDirection.strongBuy;
    if (score >= 70) return DecisionDirection.buy;
    if (score >= 50) return DecisionDirection.watch;
    if (score >= 35) return DecisionDirection.reduce;
    return DecisionDirection.avoid;
  }

  int _portfolioPercent(DailyTradeCandidate candidate) {
    if (candidate.crocScore >= 88 && candidate.riskReward >= 2.0) return 8;
    if (candidate.crocScore >= 82) return 7;
    if (candidate.crocScore >= 75) return 6;
    return 4;
  }

  List<AnalysisFactor> _factorsFor(DailyTradeCandidate candidate) {
    return [
      AnalysisFactor(
        title: 'CROC Skoru',
        detail:
            'Teknik trade kalitesi, sektor gucu ve global piyasa baglami birlikte degerlendirildi.',
        score: candidate.crocScore,
        state: _stateFor(candidate.crocScore),
      ),
      AnalysisFactor(
        title: 'Teknik Yapi',
        detail:
            'CROC teknik motorunun mevcut trend, momentum, hacim ve seviye analizi.',
        score: candidate.technicalScore,
        state: _stateFor(candidate.technicalScore),
      ),
      AnalysisFactor(
        title: 'Sektor Gucu',
        detail: '${candidate.sector} sektorunun guncel baglam skoru.',
        score: candidate.sectorScore,
        state: _stateFor(candidate.sectorScore),
      ),
      AnalysisFactor(
        title: 'Global Piyasa',
        detail: 'CROC global risk istahi skoru.',
        score: candidate.globalScore,
        state: _stateFor(candidate.globalScore),
      ),
      AnalysisFactor(
        title: 'Risk / Getiri',
        detail:
            'Mevcut teknik senaryoda R/G 1:${candidate.riskReward.toStringAsFixed(1)}.',
        score: _riskRewardScore(candidate.riskReward),
        state: candidate.riskReward >= 1.6
            ? FactorState.positive
            : FactorState.neutral,
      ),
      const AnalysisFactor(
        title: 'Kurumsal Para',
        detail:
            'Gercek kurumsal akis verisi bu karar yoluna henuz bagli degil. Sahte skor uretilmiyor.',
        score: 0,
        state: FactorState.neutral,
      ),
      const AnalysisFactor(
        title: 'Haber / KAP',
        detail:
            'KAP etki skoru ayri motor olarak tutuluyor; bu listede uydurma haber skoru yok.',
        score: 0,
        state: FactorState.neutral,
      ),
    ];
  }

  FactorState _stateFor(int score) {
    if (score >= 70) return FactorState.positive;
    if (score < 40) return FactorState.negative;
    return FactorState.neutral;
  }

  int _riskRewardScore(double rr) {
    if (rr >= 2.5) return 95;
    if (rr >= 2.0) return 88;
    if (rr >= 1.6) return 78;
    if (rr >= 1.3) return 68;
    if (rr >= 1.0) return 55;
    return 30;
  }
}
