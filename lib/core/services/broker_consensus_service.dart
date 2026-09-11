import '../models/broker_vote.dart';

class BrokerConsensusService {
  static List<BrokerVote> getVotes() {
    return const [
      BrokerVote(
        engine: 'Teknik AI',
        decision: 'AL',
        score: 94,
        reason: 'RSI + MACD pozitif',
      ),
      BrokerVote(
        engine: 'Smart Money AI',
        decision: 'GÜÇLÜ AL',
        score: 97,
        reason: 'Kurumsal para girişi var',
      ),
      BrokerVote(
        engine: 'Fon AI',
        decision: 'AL',
        score: 90,
        reason: 'Fon girişleri artıyor',
      ),
      BrokerVote(
        engine: 'News AI',
        decision: 'BEKLE',
        score: 71,
        reason: 'Haber akışı karışık',
      ),
      BrokerVote(
        engine: 'Risk AI',
        decision: 'DİKKAT',
        score: 68,
        reason: 'Direnç bölgesine yakın',
      ),
    ];
  }

  static int consensusScore() {
    final votes = getVotes();
    final total = votes.fold<int>(0, (sum, item) => sum + item.score);
    return (total / votes.length).round();
  }

  static String finalDecision() {
    final score = consensusScore();

    if (score >= 90) return 'GÜÇLÜ AL';
    if (score >= 75) return 'AL';
    if (score >= 60) return 'BEKLE';

    return 'UZAK DUR';
  }
}
