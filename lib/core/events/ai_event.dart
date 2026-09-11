import 'ai_event_type.dart';

class AiEvent {
  final String id;
  final AiEventType type;
  final DateTime occurredAt;
  final String source;
  final String title;
  final String description;
  final Map<String, Object?> payload;

  AiEvent({
    required this.type,
    required this.source,
    required this.title,
    required this.description,
    this.payload = const <String, Object?>{},
    DateTime? occurredAt,
    String? id,
  }) : occurredAt = occurredAt ?? DateTime.now(),
       id =
           id ??
           '${DateTime.now().microsecondsSinceEpoch}_${type.name}_$source';

  T? value<T>(String key) {
    final item = payload[key];
    return item is T ? item : null;
  }
}
