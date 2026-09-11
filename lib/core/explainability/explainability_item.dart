import 'score_change.dart';

class ExplainabilityItem {
  final String factor;
  final int score;
  final double weight;
  final int contribution;
  final ScoreChange change;
  final String explanation;

  const ExplainabilityItem({
    required this.factor,
    required this.score,
    required this.weight,
    required this.contribution,
    required this.change,
    required this.explanation,
  });
}
