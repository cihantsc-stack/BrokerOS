abstract interface class CacheManager {
  T? get<T>(String key);
  void set<T>(String key, T value, {Duration? ttl});
  bool contains(String key);
  void remove(String key);
  void clear();
  void purgeExpired();
}
