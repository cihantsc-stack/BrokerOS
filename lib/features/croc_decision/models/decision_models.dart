enum DecisionDirection { strongBuy, buy, watch, reduce, avoid }

extension DecisionDirectionText on DecisionDirection {
  String get title {
    switch (this) {
      case DecisionDirection.strongBuy:
        return 'GÜÇLÜ AL';
      case DecisionDirection.buy:
        return 'KADEMELİ AL';
      case DecisionDirection.watch:
        return 'İZLE';
      case DecisionDirection.reduce:
        return 'RİSK AZALT';
      case DecisionDirection.avoid:
        return 'İŞLEM YAPMA';
    }
  }
}

class DecisionSignal {
  final String code;
  final String company;
  final double price;
  final double changePercent;
  final int confidence;
  final String risk;
  final String horizon;
  final DecisionDirection direction;
  final double buyLow;
  final double buyHigh;
  final double firstTarget;
  final double mainTarget;
  final double stop;
  final int suggestedPortfolioPercent;
  final List<String> reasons;
  final List<String> invalidationRules;

  const DecisionSignal({
    required this.code,
    required this.company,
    required this.price,
    required this.changePercent,
    required this.confidence,
    required this.risk,
    required this.horizon,
    required this.direction,
    required this.buyLow,
    required this.buyHigh,
    required this.firstTarget,
    required this.mainTarget,
    required this.stop,
    required this.suggestedPortfolioPercent,
    required this.reasons,
    required this.invalidationRules,
  });
}

enum FactorState { positive, neutral, negative }

class AnalysisFactor {
  final String title;
  final String detail;
  final int score;
  final FactorState state;

  const AnalysisFactor({
    required this.title,
    required this.detail,
    required this.score,
    required this.state,
  });
}

class DecisionSnapshot {
  final String marketMode;
  final String marketSummary;
  final int marketConfidence;
  final List<DecisionSignal> opportunities;
  final DecisionSignal selected;
  final List<AnalysisFactor> factors;

  const DecisionSnapshot({
    required this.marketMode,
    required this.marketSummary,
    required this.marketConfidence,
    required this.opportunities,
    required this.selected,
    required this.factors,
  });
}
