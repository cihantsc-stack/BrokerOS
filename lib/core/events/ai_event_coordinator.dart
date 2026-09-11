import '../ai/council/council_result.dart';
import '../models/stock_analysis.dart';
import 'ai_event.dart';
import 'ai_event_bus.dart';
import 'ai_event_type.dart';

class AiEventCoordinator {
  AiEventCoordinator._();

  static final Map<String, String> _lastDecisionBySymbol = <String, String>{};
  static final Map<String, int> _lastConfidenceBySymbol = <String, int>{};

  static void process({
    required StockAnalysis stock,
    required CouncilResult council,
  }) {
    final bus = AiEventBus.instance;
    final symbol = stock.symbol;

    bus.publish(
      AiEvent(
        type: AiEventType.councilEvaluated,
        source: 'Broker Council',
        title: '$symbol konseyi hesaplandı',
        description:
            '${council.buyVotes} AL, ${council.waitVotes} BEKLE, '
            '${council.sellVotes} SAT oyu.',
        payload: <String, Object?>{
          'symbol': symbol,
          'decision': council.finalDecision,
          'confidence': council.confidence,
        },
      ),
    );

    final previousDecision = _lastDecisionBySymbol[symbol];
    if (previousDecision != null && previousDecision != council.finalDecision) {
      bus.publish(
        AiEvent(
          type: AiEventType.decisionChanged,
          source: 'Dynamic AI',
          title: '$symbol kararı değişti',
          description: '$previousDecision → ${council.finalDecision}',
          payload: <String, Object?>{
            'symbol': symbol,
            'oldDecision': previousDecision,
            'newDecision': council.finalDecision,
          },
        ),
      );

      bus.publish(
        AiEvent(
          type: AiEventType.alertCreated,
          source: 'AI Alarm',
          title: '$symbol için yeni AI alarmı',
          description: 'Broker Council kararı ${council.finalDecision} oldu.',
          payload: <String, Object?>{
            'symbol': symbol,
            'decision': council.finalDecision,
          },
        ),
      );
    }

    final previousConfidence = _lastConfidenceBySymbol[symbol];
    if (previousConfidence != null &&
        previousConfidence != council.confidence) {
      final difference = council.confidence - previousConfidence;

      bus.publish(
        AiEvent(
          type: AiEventType.confidenceChanged,
          source: 'Confidence Engine',
          title: '$symbol güven skoru güncellendi',
          description:
              '%$previousConfidence → %${council.confidence} '
              '(${difference >= 0 ? '+' : ''}$difference)',
          payload: <String, Object?>{
            'symbol': symbol,
            'oldConfidence': previousConfidence,
            'newConfidence': council.confidence,
          },
        ),
      );
    }

    bus.publish(
      AiEvent(
        type: AiEventType.actionCreated,
        source: 'Action Center',
        title: '$symbol işlem planı hazır',
        description:
            '${council.finalDecision} kararı için stop '
            '${stock.stop.toStringAsFixed(2)}, hedef '
            '${stock.target1.toStringAsFixed(2)}.',
        payload: <String, Object?>{
          'symbol': symbol,
          'stop': stock.stop,
          'target': stock.target1,
        },
      ),
    );

    _lastDecisionBySymbol[symbol] = council.finalDecision;
    _lastConfidenceBySymbol[symbol] = council.confidence;
  }
}
