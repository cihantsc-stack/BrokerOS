import 'market_scenario.dart';

class ScenarioSnapshot {
  final String symbol;
  final String decision;
  final double confidence;
  final List<MarketScenario> scenarios;
  final String aiComment;
  final List<String> inputs;

  const ScenarioSnapshot({
    required this.symbol,
    required this.decision,
    required this.confidence,
    required this.scenarios,
    required this.aiComment,
    required this.inputs,
  });
}
