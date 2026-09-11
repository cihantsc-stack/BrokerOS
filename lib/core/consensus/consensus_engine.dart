import '../agents/fund_agent.dart';
import '../agents/news_agent.dart';
import '../agents/risk_agent.dart';
import '../agents/smart_money_agent.dart';
import '../agents/technical_agent.dart';
import '../providers/provider_manager.dart';
import 'consensus_reason.dart';
import 'consensus_result.dart';
import 'consensus_vote.dart';

class ConsensusEngine {
  ConsensusEngine._();

  static final ConsensusEngine instance = ConsensusEngine._();

  final TechnicalAgent _technical = const TechnicalAgent();
  final NewsAgent _news = const NewsAgent();
  final SmartMoneyAgent _smartMoney = const SmartMoneyAgent();
  final RiskAgent _risk = const RiskAgent();
  final FundAgent _fund = const FundAgent();

  ConsensusResult evaluate({
    required String symbol,
    required ProviderBundle bundle,
  }) {
    final votes = <ConsensusVote>[];

    // Teknik veri gercekse Teknik AI oy kullanir.
    if (bundle.technical.available) {
      votes.add(_technical.vote(bundle));
    }

    // Risk AI, gercek market + gercek teknik veri ister.
    if (bundle.market.available && bundle.technical.available) {
      votes.add(_risk.vote(bundle));
    }

    // Kurumsal veri yoksa Smart Money oy kullanamaz.
    if (bundle.institution.available) {
      votes.add(_smartMoney.vote(bundle));
    }

    // Haber verisi yoksa News AI oy kullanamaz.
    if (bundle.news.available) {
      votes.add(_news.vote(bundle));
    }

    // Fon verisi yoksa Fund AI oy kullanamaz.
    if (bundle.fund.available) {
      votes.add(_fund.vote(bundle));
    }

    if (votes.isEmpty) {
      return ConsensusResult(
        symbol: symbol,
        finalSignal: ConsensusSignal.hold,
        confidence: 0,
        riskLevel: 'VERI YOK',
        votes: const [],
        reasons: const [],
        createdAt: DateTime.now(),
      );
    }

    final weighted = votes.fold<double>(
      0,
      (total, vote) => total + vote.weightedScore,
    );

    final activeWeight = votes.fold<double>(
      0,
      (total, vote) => total + vote.weight,
    );

    // Aktif ajan agirligina gore normalize.
    // Sonuc teorik olarak -2 ile +2 arasinda.
    final normalized = activeWeight <= 0 ? 0.0 : weighted / activeWeight;

    final signal = normalized >= 1.10
        ? ConsensusSignal.strongBuy
        : normalized >= 0.35
        ? ConsensusSignal.buy
        : normalized > -0.35
        ? ConsensusSignal.hold
        : normalized > -1.10
        ? ConsensusSignal.sell
        : ConsensusSignal.strongSell;

    final confidence = _confidence(votes, normalized);
    final riskLevel = _riskLevel(bundle);

    final reasons = votes
        .map(
          (vote) => ConsensusReason(
            title: vote.agent,
            detail: vote.reason,
            positive: vote.signal.numericValue > 0,
          ),
        )
        .toList(growable: false);

    return ConsensusResult(
      symbol: symbol,
      finalSignal: signal,
      confidence: confidence,
      riskLevel: riskLevel,
      votes: votes,
      reasons: reasons,
      createdAt: DateTime.now(),
    );
  }

  int _confidence(List<ConsensusVote> votes, double normalized) {
    if (votes.isEmpty) return 0;

    final totalWeight = votes.fold<double>(
      0,
      (total, vote) => total + vote.weight,
    );

    if (totalWeight <= 0) return 0;

    final weightedConfidence =
        votes.fold<double>(
          0,
          (total, vote) => total + (vote.confidence * vote.weight),
        ) /
        totalWeight;

    final direction = normalized == 0
        ? 0
        : normalized > 0
        ? 1
        : -1;

    final agreeing = votes.where((vote) {
      final value = vote.signal.numericValue;

      if (direction == 0) {
        return value == 0;
      }

      return direction > 0 ? value > 0 : value < 0;
    }).length;

    final agreement = votes.isEmpty ? 0.0 : agreeing / votes.length;

    // Veri kapsami da confidence icinde gorunur.
    // V22'de teknik+risk varsa 2/5 kapsama vardir.
    // Ancak confidence sifira ezilmez.
    final coverage = (votes.length / 5).clamp(0.0, 1.0);

    final raw =
        (weightedConfidence * 0.70) + (agreement * 20) + (coverage * 10);

    return raw.round().clamp(0, 100);
  }

  String _riskLevel(ProviderBundle bundle) {
    if (!bundle.market.available || !bundle.technical.available) {
      return 'VERI YOK';
    }

    if (bundle.technical.rsi >= 75 || bundle.market.changePercent.abs() >= 7) {
      return 'Yuksek';
    }

    if (bundle.technical.rsi >= 65 || bundle.market.changePercent.abs() >= 4) {
      return 'Orta';
    }

    return 'Dusuk';
  }
}
