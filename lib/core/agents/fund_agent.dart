import '../consensus/consensus_vote.dart';
import '../consensus/consensus_weight.dart';
import '../providers/provider_manager.dart';

class FundAgent {
  const FundAgent();

  ConsensusVote vote(ProviderBundle bundle) {
    final score = bundle.fund.score;
    final signal = score >= 85
        ? ConsensusSignal.strongBuy
        : score >= 65
        ? ConsensusSignal.buy
        : ConsensusSignal.hold;

    return ConsensusVote(
      agent: 'Fund AI',
      signal: signal,
      confidence: score,
      weight: ConsensusWeight.fund,
      reason:
          'Fon skoru $score, aylık akış ${(bundle.fund.monthlyFlow / 1000000).toStringAsFixed(0)} Mn TL.',
    );
  }
}
