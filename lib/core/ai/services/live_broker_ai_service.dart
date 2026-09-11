import '../../data_foundation/market/market_data_source.dart';
import '../../data_foundation/market/market_tick.dart';
import '../engine/broker_consensus_engine.dart';
import '../models/broker_ai_decision.dart';
import '../models/broker_ai_input.dart';

class LiveBrokerAiService {
  final MarketDataSource dataSource;
  final BrokerConsensusEngine engine;

  const LiveBrokerAiService({
    required this.dataSource,
    this.engine = const BrokerConsensusEngine(),
  });

  Future<BrokerAiDecision> buildDecision() async {
    final List<MarketTick?> ticks = await Future.wait<MarketTick?>([
      _safeFetch('USDTRY'),
      _safeFetch('EURTRY'),
      _safeFetch('XAUUSD'),
    ]);

    final MarketTick? usdTry = ticks[0];
    final MarketTick? eurTry = ticks[1];
    final MarketTick? xauUsd = ticks[2];

    final double gramGoldChange =
        (xauUsd?.changePercent ?? 0) + (usdTry?.changePercent ?? 0);

    return engine.analyze(
      BrokerAiInput(
        usdTryChange: usdTry?.changePercent ?? 0,
        eurTryChange: eurTry?.changePercent ?? 0,
        gramGoldChange: gramGoldChange,
        stockChanges: const <double>[],
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<MarketTick?> _safeFetch(String symbol) async {
    try {
      return await dataSource.fetchQuote(symbol);
    } catch (_) {
      return null;
    }
  }
}
