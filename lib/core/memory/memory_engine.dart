import '../events/ai_event.dart';
import '../events/ai_event_bus.dart';
import '../events/ai_event_type.dart';
import 'ai_memory.dart';
import 'memory_repository.dart';
import 'memory_snapshot.dart';

class MemoryEngine {
  MemoryEngine._({MemoryRepository? repository})
    : _repository =
          repository ?? InMemoryMemoryRepository(capacityPerSymbol: 100);

  static final MemoryEngine instance = MemoryEngine._();

  final MemoryRepository _repository;

  AiMemory memoryOf(String symbol) {
    return AiMemory(
      symbol: symbol,
      snapshots: _repository.findBySymbol(symbol),
    );
  }

  void record({
    required String symbol,
    required String decision,
    required int confidence,
    required String reason,
  }) {
    final before = memoryOf(symbol).latest;

    _repository.save(
      MemorySnapshot(
        symbol: symbol,
        decision: decision,
        confidence: confidence.clamp(0, 100),
        createdAt: DateTime.now(),
        reason: reason,
      ),
    );

    final after = memoryOf(symbol).latest;

    if (after == null ||
        (before != null &&
            before.decision == after.decision &&
            before.confidence == after.confidence)) {
      return;
    }

    AiEventBus.instance.publish(
      AiEvent(
        type: AiEventType.memoryWritten,
        source: 'AI Memory',
        title: '$symbol AI hafızasına kaydedildi',
        description:
            '${after.decision} kararı ve %${after.confidence} güven skoru saklandı.',
        payload: <String, Object?>{
          'symbol': symbol,
          'decision': after.decision,
          'confidence': after.confidence,
        },
      ),
    );
  }

  void clear(String symbol) {
    _repository.clearSymbol(symbol);
  }
}
