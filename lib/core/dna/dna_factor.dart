class DnaFactor {
  final String name;
  final int rawScore;
  final double weight;
  final int contribution;
  final int share;
  final String interpretation;

  const DnaFactor({
    required this.name,
    required this.rawScore,
    required this.weight,
    required this.contribution,
    required this.share,
    required this.interpretation,
  });
}
