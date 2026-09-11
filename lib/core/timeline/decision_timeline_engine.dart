import '../consensus/consensus_result.dart';
import '../consensus/consensus_vote.dart';
import '../providers/provider_manager.dart';
import 'decision_change.dart';
import 'decision_snapshot.dart';
import 'timeline_repository.dart';

class DecisionTimelineEngine {
  DecisionTimelineEngine._({TimelineRepository? repository})
    : _repository = repository ?? InMemoryTimelineRepository();

  static final DecisionTimelineEngine instance = DecisionTimelineEngine._();

  final TimelineRepository _repository;

  void record({
    required ConsensusResult result,
    required ProviderBundle bundle,
  }) {
    _repository.save(
      DecisionSnapshot(
        id: '${result.symbol}-${result.createdAt.microsecondsSinceEpoch}',
        symbol: result.symbol,
        signal: result.finalSignal,
        confidence: result.confidence,
        riskLevel: result.riskLevel,
        technicalScore: bundle.technical.score,
        newsScore: bundle.news.score,
        smartMoneyScore: bundle.institution.score,
        fundScore: bundle.fund.score,
        price: bundle.market.price,
        changePercent: bundle.market.changePercent,
        createdAt: result.createdAt,
      ),
    );
  }

  List<DecisionSnapshot> historyOf(String symbol, {int limit = 20}) {
    return _repository.findBySymbol(symbol, limit: limit);
  }

  List<DecisionChange> changesFor({
    required DecisionSnapshot current,
    DecisionSnapshot? previous,
  }) {
    if (previous == null) {
      return <DecisionChange>[
        DecisionChange(
          label: 'İlk kayıt',
          previousValue: '—',
          currentValue: current.signal.label,
          positive: true,
        ),
        DecisionChange(
          label: 'Güven',
          previousValue: '—',
          currentValue: '%${current.confidence}',
          positive: true,
        ),
        DecisionChange(
          label: 'Risk',
          previousValue: '—',
          currentValue: current.riskLevel,
          positive: current.riskLevel != 'Yüksek',
        ),
      ];
    }

    final changes = <DecisionChange>[];

    _addChange(
      changes,
      label: 'CROC AI Kararı',
      previous: previous.signal.label,
      current: current.signal.label,
      positive: current.signal.numericValue >= previous.signal.numericValue,
    );

    _addChange(
      changes,
      label: 'Güven',
      previous: '%${previous.confidence}',
      current: '%${current.confidence}',
      positive: current.confidence >= previous.confidence,
    );

    _addChange(
      changes,
      label: 'Teknik skor',
      previous: '${previous.technicalScore}',
      current: '${current.technicalScore}',
      positive: current.technicalScore >= previous.technicalScore,
    );

    _addChange(
      changes,
      label: 'Smart Money',
      previous: '${previous.smartMoneyScore}',
      current: '${current.smartMoneyScore}',
      positive: current.smartMoneyScore >= previous.smartMoneyScore,
    );

    _addChange(
      changes,
      label: 'Haber skoru',
      previous: '${previous.newsScore}',
      current: '${current.newsScore}',
      positive: current.newsScore >= previous.newsScore,
    );

    _addChange(
      changes,
      label: 'Fon skoru',
      previous: '${previous.fundScore}',
      current: '${current.fundScore}',
      positive: current.fundScore >= previous.fundScore,
    );

    _addChange(
      changes,
      label: 'Risk',
      previous: previous.riskLevel,
      current: current.riskLevel,
      positive: _riskValue(current.riskLevel) <= _riskValue(previous.riskLevel),
    );

    _addChange(
      changes,
      label: 'Fiyat',
      previous: previous.price.toStringAsFixed(2),
      current: current.price.toStringAsFixed(2),
      positive: current.price >= previous.price,
    );

    if (changes.isEmpty) {
      changes.add(
        const DecisionChange(
          label: 'Durum',
          previousValue: 'Aynı',
          currentValue: 'Anlamlı değişim yok',
          positive: true,
        ),
      );
    }

    return changes;
  }

  void clear(String symbol) {
    _repository.clear(symbol);
  }

  void _addChange(
    List<DecisionChange> target, {
    required String label,
    required String previous,
    required String current,
    required bool positive,
  }) {
    if (previous == current) return;

    target.add(
      DecisionChange(
        label: label,
        previousValue: previous,
        currentValue: current,
        positive: positive,
      ),
    );
  }

  int _riskValue(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return 1;
      case 'orta':
        return 2;
      case 'yüksek':
        return 3;
      default:
        return 2;
    }
  }
}
