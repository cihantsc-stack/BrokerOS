import '../consensus/consensus_vote.dart';
import '../consensus/consensus_weight.dart';
import '../providers/provider_manager.dart';

class NewsAgent {
  const NewsAgent();

  ConsensusVote vote(ProviderBundle bundle) {
    final score = bundle.news.score;
    final signal = score >= 85
        ? ConsensusSignal.strongBuy
        : score >= 65
        ? ConsensusSignal.buy
        : score >= 45
        ? ConsensusSignal.hold
        : ConsensusSignal.sell;

    return ConsensusVote(
      agent: 'News AI',
      signal: signal,
      confidence: score,
      weight: ConsensusWeight.news,
      reason: 'Haber duyarlılığı ${bundle.news.sentiment}, skor $score.',
    );
  }
}
