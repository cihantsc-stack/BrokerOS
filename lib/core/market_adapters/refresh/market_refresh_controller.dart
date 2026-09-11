class MarketRefreshController {
  MarketRefreshController._();

  static final MarketRefreshController instance = MarketRefreshController._();

  DateTime? _lastRefreshAt;

  DateTime? get lastRefreshAt => _lastRefreshAt;

  bool get canRefresh {
    final DateTime? last = _lastRefreshAt;

    if (last == null) {
      return true;
    }

    return DateTime.now().difference(last) > const Duration(seconds: 2);
  }

  void markRefreshed() {
    _lastRefreshAt = DateTime.now();
  }
}
