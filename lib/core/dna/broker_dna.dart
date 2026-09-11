import 'decision_dna.dart';
import 'stability_score.dart';

class BrokerDna {
  final DecisionDna decisionDna;
  final StabilityScore stability;

  const BrokerDna({required this.decisionDna, required this.stability});
}
