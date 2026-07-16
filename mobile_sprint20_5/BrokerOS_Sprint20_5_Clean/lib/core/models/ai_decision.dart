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
    this.missions = const [],
    this.warnings = const [],
    this.strongestFactor = '',
    this.weakestFactor = '',
    this.nextTrigger = '',
    this.timeline = const [],
  });

  AiDecision copyWith({
    int? pusuScore,
    String? decision,
    String? explanation,
    int? confidence,
    String? risk,
    List<String>? missions,
    List<String>? warnings,
    String? strongestFactor,
    String? weakestFactor,
    String? nextTrigger,
    List<AiTimelineStep>? timeline,
  }) {
    return AiDecision(
      pusuScore: pusuScore ?? this.pusuScore,
      decision: decision ?? this.decision,
      explanation: explanation ?? this.explanation,
      confidence: confidence ?? this.confidence,
      risk: risk ?? this.risk,
      missions: missions ?? this.missions,
      warnings: warnings ?? this.warnings,
      strongestFactor: strongestFactor ?? this.strongestFactor,
      weakestFactor: weakestFactor ?? this.weakestFactor,
      nextTrigger: nextTrigger ?? this.nextTrigger,
      timeline: timeline ?? this.timeline,
    );
  }
}