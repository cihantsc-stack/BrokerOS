import 'dart:async';

import 'ai_event.dart';
import 'ai_event_listener.dart';
import 'ai_event_type.dart';
import 'event_history.dart';

class AiEventBus {
  AiEventBus._();

  static final AiEventBus instance = AiEventBus._();

  final StreamController<AiEvent> _controller =
      StreamController<AiEvent>.broadcast(sync: true);

  final EventHistory history = EventHistory();

  Stream<AiEvent> get stream => _controller.stream;

  Stream<AiEvent> on(AiEventType type) =>
      _controller.stream.where((event) => event.type == type);

  Stream<AiEvent> from(String source) =>
      _controller.stream.where((event) => event.source == source);

  StreamSubscription<AiEvent> listen(
    AiEventCallback callback, {
    AiEventType? type,
    String? source,
  }) {
    Stream<AiEvent> selected = _controller.stream;

    if (type != null) {
      selected = selected.where((event) => event.type == type);
    }

    if (source != null) {
      selected = selected.where((event) => event.source == source);
    }

    return selected.listen(callback);
  }

  StreamSubscription<AiEvent> attach(AiEventListener listener) =>
      _controller.stream.listen(listener.onAiEvent);

  void publish(AiEvent event) {
    history.add(event);
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  Future<void> dispose() => _controller.close();
}
