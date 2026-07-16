import '../models/broker_consensus.dart';

class DecisionEngine {
  const DecisionEngine._();

  static String build(BrokerConsensus consensus) {
    final score = consensus.score;
    final riskScore = consensus.riskScore;
    final smartMoney = consensus.smartMoneyScore;
    final momentum = consensus.momentumScore;
    final technical = consensus.technicalScore;

    if (riskScore < 45) {
      return 'BEKLE';
    }

    if (score >= 88 &&
        smartMoney >= 82 &&
        technical >= 80 &&
        momentum >= 78) {
      return 'GÜÇLÜ AL';
    }

    if (score >= 76 &&
        smartMoney >= 68 &&
        technical >= 68) {
      return 'SEÇİCİ AL';
    }

    if (score >= 58) {
      return 'BEKLE';
    }

    if (score >= 42) {
      return 'RİSK AZALT';
    }

    return 'SAT';
  }
}