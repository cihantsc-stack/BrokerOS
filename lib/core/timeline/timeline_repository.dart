import 'decision_snapshot.dart';

abstract interface class TimelineRepository {
  void save(DecisionSnapshot snapshot);

  List<DecisionSnapshot> findBySymbol(String symbol, {int limit = 30});

  void clear(String symbol);
}

class InMemoryTimelineRepository implements TimelineRepository {
  final Map<String, List<DecisionSnapshot>> _storage =
      <String, List<DecisionSnapshot>>{};

  @override
  void save(DecisionSnapshot snapshot) {
    final items = _storage.putIfAbsent(
      snapshot.symbol,
      () => <DecisionSnapshot>[],
    );

    if (items.isNotEmpty) {
      final last = items.last;
      final sameState =
          last.signal == snapshot.signal &&
          last.confidence == snapshot.confidence &&
          last.riskLevel == snapshot.riskLevel &&
          last.technicalScore == snapshot.technicalScore &&
          last.newsScore == snapshot.newsScore &&
          last.smartMoneyScore == snapshot.smartMoneyScore &&
          last.fundScore == snapshot.fundScore &&
          last.price == snapshot.price;

      if (sameState) return;
    }

    items.add(snapshot);

    if (items.length > 100) {
      items.removeRange(0, items.length - 100);
    }
  }

  @override
  List<DecisionSnapshot> findBySymbol(String symbol, {int limit = 30}) {
    final items = _storage[symbol] ?? const <DecisionSnapshot>[];
    final start = items.length > limit ? items.length - limit : 0;

    return List<DecisionSnapshot>.unmodifiable(items.sublist(start).reversed);
  }

  @override
  void clear(String symbol) {
    _storage.remove(symbol);
  }
}
