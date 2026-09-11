import '../ai/broker_ai_engine.dart';
import '../models/ai_decision.dart';
import '../repository/market_repository.dart';

class DecisionService {
  final MarketRepository repository;

  const DecisionService(this.repository);

  AiDecision getTodayDecision() {
    final snapshot = repository.getTodaySnapshot();
    return BrokerAiEngine.analyze(snapshot);
  }
}
