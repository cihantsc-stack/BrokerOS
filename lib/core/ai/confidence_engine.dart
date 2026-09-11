class ConfidenceEngine {
  const ConfidenceEngine();

  int calculate({
    required int score,
    required int positiveSignals,
    required int negativeSignals,
  }) {
    final value = score + (positiveSignals * 2) - negativeSignals;

    return value.clamp(40, 98);
  }
}
