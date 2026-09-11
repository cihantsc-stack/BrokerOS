import '../consensus/consensus_vote.dart';
import '../consensus/consensus_weight.dart';
import '../providers/provider_manager.dart';

class SmartMoneyAgent {
  const SmartMoneyAgent();

  ConsensusVote vote(ProviderBundle bundle) {
    final score = bundle.institution.score;
    final signal = score >= 90
        ? ConsensusSignal.strongBuy
        : score >= 70
        ? ConsensusSignal.buy
        : score >= 45
        ? ConsensusSignal.hold
        : ConsensusSignal.sell;

    return ConsensusVote(
      agent: 'Smart Money AI',
      signal: signal,
      confidence: score,
      weight: ConsensusWeight.smartMoney,
      reason:
          'Kurumsal skor $score, net akış ${(bundle.institution.netFlow / 1000000).toStringAsFixed(0)} Mn TL.',
    );
  }
}
