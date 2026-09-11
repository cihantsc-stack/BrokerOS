import 'absorption_result.dart';

enum FlowContextState {
  dataWaiting,
  neutral,
  sellingPressure,
  possibleAbsorption,
  possibleDistribution,
  mixed,
}

class FlowContextResult {
  final String symbol;
  final FlowContextState state;
  final AbsorptionResult absorption;

  final int? confidence;
  final String summary;
  final List<String> observations;

  final bool affectsMasterDecision;
  final DateTime generatedAt;

  const FlowContextResult({
    required this.symbol,
    required this.state,
    required this.absorption,
    required this.confidence,
    required this.summary,
    this.observations = const <String>[],
    this.affectsMasterDecision = false,
    required this.generatedAt,
  });

  const FlowContextResult.dataWaiting({
    required this.symbol,
    required this.generatedAt,
  }) : state = FlowContextState.dataWaiting,
       absorption = const AbsorptionResult.dataWaiting(),
       confidence = null,
       summary = 'AKD / fon akisi icin gercek veri bekleniyor.',
       observations = const <String>[],
       affectsMasterDecision = false;

  bool get available => state != FlowContextState.dataWaiting;
}
