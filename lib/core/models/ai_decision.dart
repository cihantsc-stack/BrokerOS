import 'ai_timeline_step.dart';

class AiDecision {
  final int pusuScore;
  final String decision;
  final String explanation;
  final int confidence;
  final String risk;
  final List<String> missions;
  final List<String> warnings;
  final String strongestFactor;
  final String weakestFactor;
  final String nextTrigger;
  final List<AiTimelineStep> timeline;

  const AiDecision({
    required this.pusuScore,
    required this.decision,
    required this.explanation,
    required this.confidence,
    required this.risk,
    required this.missions,
    required this.warnings,
    required this.strongestFactor,
    required this.weakestFactor,
    required this.nextTrigger,
    required this.timeline,
  });

  bool get isBullish => decision.contains('AL');

  bool get isBearish => decision.contains('SAT');

  bool get isNeutral => !isBullish && !isBearish;
}
