class DecisionChange {
  final String label;
  final String previousValue;
  final String currentValue;
  final bool positive;

  const DecisionChange({
    required this.label,
    required this.previousValue,
    required this.currentValue,
    required this.positive,
  });
}
