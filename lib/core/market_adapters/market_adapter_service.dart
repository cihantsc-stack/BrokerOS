import 'models/normalized_market_quote.dart';
import 'orchestration/market_adapter_orchestrator.dart';
import 'refresh/market_refresh_controller.dart';

class MarketAdapterService {
  MarketAdapterService._();

  static final MarketAdapterService instance = MarketAdapterService._();

  Future<List<NormalizedMarketQuote>> load(String selectedStock) async {
    if (!MarketRefreshController.instance.canRefresh) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    final List<NormalizedMarketQuote> result = await MarketAdapterOrchestrator
        .instance
        .fetchDashboard(selectedStock);

    MarketRefreshController.instance.markRefreshed();

    return result;
  }
}
