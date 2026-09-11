import 'ai_alert.dart';

abstract interface class AlertRepository {
  void save(AiAlert alert);

  List<AiAlert> findBySymbol(String symbol, {int limit = 20});

  void markAllRead(String symbol);

  void clear(String symbol);
}

class InMemoryAlertRepository implements AlertRepository {
  final Map<String, List<AiAlert>> _storage = <String, List<AiAlert>>{};

  @override
  void save(AiAlert alert) {
    final alerts = _storage.putIfAbsent(alert.symbol, () => <AiAlert>[]);

    final duplicate =
        alerts.isNotEmpty &&
        alerts.last.title == alert.title &&
        alerts.last.description == alert.description;

    if (duplicate) return;

    alerts.add(alert);

    if (alerts.length > 50) {
      alerts.removeRange(0, alerts.length - 50);
    }
  }

  @override
  List<AiAlert> findBySymbol(String symbol, {int limit = 20}) {
    final alerts = _storage[symbol] ?? const <AiAlert>[];
    final start = alerts.length > limit ? alerts.length - limit : 0;

    return List<AiAlert>.unmodifiable(alerts.sublist(start).reversed);
  }

  @override
  void markAllRead(String symbol) {
    final alerts = _storage[symbol];
    if (alerts == null) return;

    _storage[symbol] = alerts
        .map((alert) => alert.copyWith(isRead: true))
        .toList();
  }

  @override
  void clear(String symbol) {
    _storage.remove(symbol);
  }
}
