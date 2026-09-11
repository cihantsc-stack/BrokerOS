class ScoreChange {
  final int previous;
  final int current;

  const ScoreChange({required this.previous, required this.current});

  int get delta => current - previous;
}
