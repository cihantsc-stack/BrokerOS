class DiskCache {
  DiskCache._();

  static final DiskCache instance = DiskCache._();

  final Map<String, String> _storage = <String, String>{};

  int get itemCount => _storage.length;

  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }

  Future<String?> read(String key) async {
    return _storage[key];
  }

  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  Future<void> clear() async {
    _storage.clear();
  }
}
