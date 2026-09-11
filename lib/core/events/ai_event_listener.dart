import 'ai_event.dart';

typedef AiEventCallback = void Function(AiEvent event);

abstract interface class AiEventListener {
  void onAiEvent(AiEvent event);
}
