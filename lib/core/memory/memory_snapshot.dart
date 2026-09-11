class MemorySnapshot {
  final String symbol;
  final String decision;
  final int confidence;
  final DateTime createdAt;
  final String reason;

  const MemorySnapshot({
    required this.symbol,
    required this.decision,
    required this.confidence,
    required this.createdAt,
    required this.reason,
  });
}
