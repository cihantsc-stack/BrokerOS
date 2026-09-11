import 'cache_entry.dart';

class MemoryCache {
  MemoryCache._();

  static final MemoryCache instance = MemoryCache._();

  final Map<String, CacheEntry<Object>> _entries =
      <String, CacheEntry<Object>>{};

  int get itemCount => _entries.length;

  void put<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 1),
  }) {
    _entries[key] = CacheEntry<Object>(
      value: value as Object,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
  }

  T? get<T>(String key) {
    final CacheEntry<Object>? entry = _entries[key];

    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  bool containsFresh(String key) {
    final CacheEntry<Object>? entry = _entries[key];

    if (entry == null) {
      return false;
    }

    if (entry.isExpired) {
      _entries.remove(key);
      return false;
    }

    return true;
  }

  void remove(String key) {
    _entries.remove(key);
  }

  void clear() {
    _entries.clear();
  }
}
