import 'dart:async';

import '../events/ai_event.dart';
import '../events/ai_event_bus.dart';
import '../events/ai_event_type.dart';
import 'ai_alert.dart';
import 'alert_repository.dart';

class AiAlarmEngine {
  AiAlarmEngine._({AlertRepository? repository})
    : _repository = repository ?? InMemoryAlertRepository() {
    _subscription = AiEventBus.instance.stream.listen(_handleEvent);
  }

  static final AiAlarmEngine instance = AiAlarmEngine._();

  final AlertRepository _repository;
  StreamSubscription<AiEvent>? _subscription;

  List<AiAlert> alertsOf(String symbol) {
    return _repository.findBySymbol(symbol);
  }

  int unreadCount(String symbol) {
    return alertsOf(symbol).where((alert) => !alert.isRead).length;
  }

  void markAllRead(String symbol) {
    _repository.markAllRead(symbol);
  }

  void clear(String symbol) {
    _repository.clear(symbol);
  }

  void _handleEvent(AiEvent event) {
    final symbol = event.value<String>('symbol');
    if (symbol == null || symbol.isEmpty) return;

    final severity = _severityOf(event.type);
    if (severity == null) return;

    _repository.save(
      AiAlert(
        id: event.id,
        symbol: symbol,
        title: event.title,
        description: event.description,
        severity: severity,
        createdAt: event.occurredAt,
      ),
    );
  }

  AiAlertSeverity? _severityOf(AiEventType type) {
    switch (type) {
      case AiEventType.alertCreated:
      case AiEventType.riskChanged:
        return AiAlertSeverity.critical;
      case AiEventType.decisionChanged:
      case AiEventType.confidenceChanged:
      case AiEventType.smartMoneyChanged:
      case AiEventType.newsChanged:
      case AiEventType.momentumChanged:
        return AiAlertSeverity.warning;
      case AiEventType.marketUpdated:
      case AiEventType.councilEvaluated:
      case AiEventType.actionCreated:
      case AiEventType.memoryWritten:
        return AiAlertSeverity.info;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
