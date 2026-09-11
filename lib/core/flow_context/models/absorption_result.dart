enum AbsorptionState { dataWaiting, low, medium, high }

class AbsorptionResult {
  final AbsorptionState state;
  final int? score;
  final double? coverageRatio;
  final String status;
  final List<String> reasons;

  const AbsorptionResult({
    required this.state,
    required this.score,
    required this.coverageRatio,
    required this.status,
    this.reasons = const <String>[],
  });

  const AbsorptionResult.dataWaiting({this.status = 'VERI BEKLENIYOR'})
    : state = AbsorptionState.dataWaiting,
      score = null,
      coverageRatio = null,
      reasons = const <String>[];

  bool get available => state != AbsorptionState.dataWaiting;
}
