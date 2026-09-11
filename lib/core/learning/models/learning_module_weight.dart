class LearningModuleWeight {
  final String module;
  final double baseWeight;
  final double adaptiveWeight;
  final int successRate;
  final String insight;

  const LearningModuleWeight({
    required this.module,
    required this.baseWeight,
    required this.adaptiveWeight,
    required this.successRate,
    required this.insight,
  });

  double get change => adaptiveWeight - baseWeight;

  String get changeLabel {
    final String sign = change >= 0 ? '+' : '';
    return '$sign${(change * 100).toStringAsFixed(1)}%';
  }
}
