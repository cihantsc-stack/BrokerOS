import 'ai_event.dart';
import 'ai_event_type.dart';

class EventHistory {
  final int capacity;
  final List<AiEvent> _events = <AiEvent>[];

  EventHistory({this.capacity = 200}) : assert(capacity > 0);

  List<AiEvent> get all => List<AiEvent>.unmodifiable(_events);
  int get length => _events.length;
  AiEvent? get latest => _events.isEmpty ? null : _events.last;

  void add(AiEvent event) {
    _events.add(event);
    if (_events.length > capacity) {
      _events.removeRange(0, _events.length - capacity);
    }
  }

  List<AiEvent> byType(AiEventType type) =>
      List<AiEvent>.unmodifiable(_events.where((e) => e.type == type));

  List<AiEvent> bySource(String source) =>
      List<AiEvent>.unmodifiable(_events.where((e) => e.source == source));

  void clear() => _events.clear();
}
