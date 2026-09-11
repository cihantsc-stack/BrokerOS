import 'ai_event.dart';
import 'ai_event_type.dart';

class MarketEvent extends AiEvent {
  MarketEvent({
    required String symbol,
    required String title,
    required String description,
    required Map<String, Object?> marketData,
    DateTime? occurredAt,
  }) : super(
         type: AiEventType.marketUpdated,
         source: 'Market',
         title: title,
         description: description,
         occurredAt: occurredAt,
         payload: <String, Object?>{'symbol': symbol, ...marketData},
       );

  String get symbol => value<String>('symbol') ?? '';
}
