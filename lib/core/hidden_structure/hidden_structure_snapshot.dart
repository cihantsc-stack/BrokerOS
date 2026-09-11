import 'hidden_structure_signal.dart';

class HiddenStructureSnapshot {
  final String symbol;
  final double overallScore;
  final String marketMode;
  final List<HiddenStructureSignal> signals;
  final List<String> evidence;
  final String aiComment;
  final DateTime generatedAt;

  const HiddenStructureSnapshot({
    required this.symbol,
    required this.overallScore,
    required this.marketMode,
    required this.signals,
    required this.evidence,
    required this.aiComment,
    required this.generatedAt,
  });
}
