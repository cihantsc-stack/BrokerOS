enum MarketScenarioType { bullish, neutral, bearish }

extension MarketScenarioTypeLabel on MarketScenarioType {
  String get label {
    switch (this) {
      case MarketScenarioType.bullish:
        return 'YÜKSELİŞ';
      case MarketScenarioType.neutral:
        return 'YATAY';
      case MarketScenarioType.bearish:
        return 'GERİ ÇEKİLME';
    }
  }
}

class MarketScenario {
  final MarketScenarioType type;
  final double probability;
  final double minReturnPercent;
  final double maxReturnPercent;
  final String timeHorizon;
  final String explanation;

  const MarketScenario({
    required this.type,
    required this.probability,
    required this.minReturnPercent,
    required this.maxReturnPercent,
    required this.timeHorizon,
    required this.explanation,
  });
}
