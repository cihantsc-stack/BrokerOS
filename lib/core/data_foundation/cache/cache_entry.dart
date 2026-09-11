class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration ttl;

  const CacheEntry({
    required this.value,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}
