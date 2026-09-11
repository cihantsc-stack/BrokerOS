import 'cache_manager.dart';

class MemoryCache implements CacheManager {
  final Map<String, _CacheEntry<Object?>> _entries =
      <String, _CacheEntry<Object?>>{};

  @override
  T? get<T>(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    final value = entry.value;
    return value is T ? value : null;
  }

  @override
  void set<T>(String key, T value, {Duration? ttl}) {
    _entries[key] = _CacheEntry<Object?>(
      value: value,
      expiresAt: ttl == null ? null : DateTime.now().add(ttl),
    );
  }

  @override
  bool contains(String key) => get<Object?>(key) != null;

  @override
  void remove(String key) => _entries.remove(key);

  @override
  void clear() => _entries.clear();

  @override
  void purgeExpired() {
    final keys = _entries.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    for (final key in keys) {
      _entries.remove(key);
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime? expiresAt;
  const _CacheEntry({required this.value, required this.expiresAt});
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
