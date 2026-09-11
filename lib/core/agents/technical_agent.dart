import '../consensus/consensus_vote.dart';
import '../consensus/consensus_weight.dart';
import '../providers/provider_manager.dart';

class TechnicalAgent {
  const TechnicalAgent();

  ConsensusVote vote(ProviderBundle bundle) {
    final score = bundle.technical.score;
    final signal = score >= 90
        ? ConsensusSignal.strongBuy
        : score >= 70
        ? ConsensusSignal.buy
        : score >= 45
        ? ConsensusSignal.hold
        : ConsensusSignal.sell;

    return ConsensusVote(
      agent: 'Technical AI',
      signal: signal,
      confidence: score,
      weight: ConsensusWeight.technical,
      reason:
          'Teknik skor $score, RSI ${bundle.technical.rsi.toStringAsFixed(0)}.',
    );
  }
}
