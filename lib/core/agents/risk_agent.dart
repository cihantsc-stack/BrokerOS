import '../consensus/consensus_vote.dart';
import '../consensus/consensus_weight.dart';
import '../providers/provider_manager.dart';

class RiskAgent {
  const RiskAgent();

  ConsensusVote vote(ProviderBundle bundle) {
    final change = bundle.market.changePercent;
    final rsi = bundle.technical.rsi;
    final risky = rsi >= 75 || change.abs() >= 7;
    final confidence = risky ? 82 : 76;

    return ConsensusVote(
      agent: 'Risk AI',
      signal: risky ? ConsensusSignal.hold : ConsensusSignal.buy,
      confidence: confidence,
      weight: ConsensusWeight.risk,
      reason: risky
          ? 'Volatilite veya aşırı alım riski yükseldi.'
          : 'Fiyat hareketi ve RSI kabul edilebilir riskte.',
    );
  }
}
