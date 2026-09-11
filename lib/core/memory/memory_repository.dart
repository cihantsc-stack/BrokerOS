import 'memory_snapshot.dart';

abstract interface class MemoryRepository {
  void save(MemorySnapshot snapshot);

  List<MemorySnapshot> findBySymbol(String symbol, {int limit = 100});

  void clearSymbol(String symbol);

  void clearAll();
}

class InMemoryMemoryRepository implements MemoryRepository {
  final int capacityPerSymbol;
  final Map<String, List<MemorySnapshot>> _storage =
      <String, List<MemorySnapshot>>{};

  InMemoryMemoryRepository({this.capacityPerSymbol = 100})
    : assert(capacityPerSymbol > 0);

  @override
  void save(MemorySnapshot snapshot) {
    final list = _storage.putIfAbsent(
      snapshot.symbol,
      () => <MemorySnapshot>[],
    );

    final duplicate =
        list.isNotEmpty &&
        list.last.decision == snapshot.decision &&
        list.last.confidence == snapshot.confidence;

    if (duplicate) return;

    list.add(snapshot);

    if (list.length > capacityPerSymbol) {
      list.removeRange(0, list.length - capacityPerSymbol);
    }
  }

  @override
  List<MemorySnapshot> findBySymbol(String symbol, {int limit = 100}) {
    final items = _storage[symbol] ?? const <MemorySnapshot>[];
    final start = items.length > limit ? items.length - limit : 0;

    return List<MemorySnapshot>.unmodifiable(items.sublist(start));
  }

  @override
  void clearSymbol(String symbol) {
    _storage.remove(symbol);
  }

  @override
  void clearAll() {
    _storage.clear();
  }
}
