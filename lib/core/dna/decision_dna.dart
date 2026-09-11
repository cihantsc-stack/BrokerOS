import 'dna_factor.dart';

class DecisionDna {
  final String decision;
  final int totalPower;
  final String dominantGene;
  final String profile;
  final List<DnaFactor> factors;

  const DecisionDna({
    required this.decision,
    required this.totalPower,
    required this.dominantGene,
    required this.profile,
    required this.factors,
  });
}
