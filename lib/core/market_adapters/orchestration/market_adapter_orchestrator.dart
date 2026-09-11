import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';
import '../normalization/market_data_normalizer.dart';
import '../registry/market_adapter_registry.dart';
import '../validation/market_quote_validator.dart';

class MarketAdapterOrchestrator {
  MarketAdapterOrchestrator._();

  static final MarketAdapterOrchestrator instance =
      MarketAdapterOrchestrator._();

  final MarketAdapterRegistry _registry = MarketAdapterRegistry.instance;

  final MarketDataNormalizer _normalizer = const MarketDataNormalizer();

  final MarketQuoteValidator _validator = const MarketQuoteValidator();

  Future<List<NormalizedMarketQuote>> fetchDashboard(
    String selectedStock,
  ) async {
    final List<Future<NormalizedMarketQuote>> jobs =
        <Future<NormalizedMarketQuote>>[
          _fetch(MarketAssetType.bist, selectedStock),
          _fetch(MarketAssetType.viop, 'XU030'),
          _fetch(MarketAssetType.forex, 'USDTRY'),
          _fetch(MarketAssetType.gold, 'GRAMALTIN'),
          _fetch(MarketAssetType.crypto, 'BTCUSDT'),
          _fetch(MarketAssetType.tefas, 'MAC'),
        ];

    return Future.wait(jobs);
  }

  Future<NormalizedMarketQuote> _fetch(
    MarketAssetType type,
    String symbol,
  ) async {
    final NormalizedMarketQuote raw = await _registry
        .adapterFor(type)
        .fetch(symbol);

    final NormalizedMarketQuote normalized = _normalizer.normalize(raw);

    if (!_validator.isValid(normalized)) {
      final String message = _validator.validate(normalized).join(' ');

      throw StateError(message);
    }

    return normalized;
  }
}
