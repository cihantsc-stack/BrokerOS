class BrokerAiInput {
  final double? bist100Change;
  final double? bist30Change;
  final double? viop30Change;

  final double usdTryChange;
  final double eurTryChange;
  final double gramGoldChange;

  final List<double> stockChanges;
  final DateTime timestamp;

  const BrokerAiInput({
    this.bist100Change,
    this.bist30Change,
    this.viop30Change,
    required this.usdTryChange,
    required this.eurTryChange,
    required this.gramGoldChange,
    this.stockChanges = const <double>[],
    required this.timestamp,
  });
}
