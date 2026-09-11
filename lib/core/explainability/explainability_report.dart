import 'explainability_item.dart';

class ExplainabilityReport {
  final String finalDecision;
  final int totalScore;
  final String dominantFactor;
  final String summary;
  final List<ExplainabilityItem> items;

  const ExplainabilityReport({
    required this.finalDecision,
    required this.totalScore,
    required this.dominantFactor,
    required this.summary,
    required this.items,
  });
}
